#!/usr/bin/env node
/**
 * Devin experiment harness — measure SigMap's impact on a real autonomous agent.
 *
 * For each task, runs Devin two ways (prompt-injection A/B):
 *   A control   : task prompt only (Devin explores the repo itself)
 *   B treatment : SigMap signature map + same task prompt
 * Captures per session: ACUs (best-effort), wall-clock, step count, PR, status.
 * Writes paired results + a report.
 *
 * COSTS ACUs (real Devin Max budget). Defaults to --pilot (1 task, both arms,
 * 1 rep) so you can calibrate ACUs/session before a full run.
 *
 * Usage:
 *   DEVIN_API_KEY=... node scripts/devin-experiment.mjs --pilot
 *   DEVIN_API_KEY=... node scripts/devin-experiment.mjs --reps 3 --max 12
 *   node scripts/devin-experiment.mjs --report-only   # re-aggregate saved sessions
 */
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync, readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir, homedir } from "node:os";
import { bm25rank } from "./rerank.mjs";

const HERE = dirname(fileURLToPath(import.meta.url));
const SIGMAP = join(homedir(), "sigmap", "gen-context.js");
const OUT = join(homedir(), "results", "devin");
const SESS_DIR = join(OUT, "sessions");
const DEVIN = "https://api.devin.ai/v1";
const KEY = process.env.DEVIN_API_KEY;

const args = process.argv.slice(2);
const flag = (n) => args.includes(n);
const opt = (n, d) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d; };
const PILOT = flag("--pilot");
const REPORT_ONLY = flag("--report-only");
const REPS = PILOT ? 1 : Number(opt("--reps", 3));
const MAX = PILOT ? 1 : Number(opt("--max", 99));
const ARMS = PILOT ? ["A", "B"] : (opt("--arm", "both") === "both" ? ["A", "B"] : [opt("--arm")]);
const POLL_MAX_MS = Number(opt("--maxwait", 1800)) * 1000;
const TASKS_FILE = opt("--tasks", join(HERE, "devin-tasks.jsonl"));
mkdirSync(SESS_DIR, { recursive: true });

// ── SigMap RANKED context for a task (top-K files via `sigmap ask`) ───────────
// Devin caps prompts at ~30k chars, so we inject only the files SigMap ranks
// for THIS task (the real `sigmap ask` workflow), not the whole signature map.
const CTX_CAP = 22000; // chars — leave room under Devin's 30k prompt limit
const ctxCache = new Map();
function sigmapRanked(repoUrl, query) {
  const k = `${repoUrl}::${query}`;
  if (ctxCache.has(k)) return ctxCache.get(k);
  const work = mkdtempSync(join(tmpdir(), "devin-ctx-"));
  let out = "";
  try {
    execFileSync("git", ["clone", "--depth", "1", "-q", repoUrl, join(work, "r")], { timeout: 240000, stdio: "ignore" });
    const dir = join(work, "r");
    writeFileSync(join(dir, "gen-context.config.json"), JSON.stringify({
      srcDirs: ["."], maxDepth: 12, autoMaxTokens: false, maxTokens: 200000, coverageTarget: 0.9,
      exclude: ["node_modules", ".git", "dist", "build", "target", "vendor", "test", "tests", "docs", "website", "i18n", "examples"],
    }));
    execFileSync(process.execPath, [SIGMAP], { cwd: dir, stdio: "ignore", timeout: 180000 });
    // Pull a broad candidate set, then BM25 re-rank it (identifier-split + path
    // boost) — proven to lift hit@5 75.3%→82.4% over SigMap's TF-IDF.
    const candidates = JSON.parse(execFileSync(process.execPath, [SIGMAP, "--query", query, "--top", "100", "--json"], { cwd: dir, encoding: "utf8", timeout: 120000 })).results || [];
    let ranked = bm25rank(query, candidates);
    // Drop prose/doc files (.md/.rst/…): natural-language tasks match docs over
    // code, which then crowd out real source in the injected context (see akka).
    ranked = ranked.filter((r) => !/\.(md|mdx|markdown|rst|txt|adoc)$/i.test(r.file)).slice(0, 15);
    for (const r of ranked) {
      const block = `// ${r.file}\n${r.sigs.join("\n")}\n\n`;
      if (out.length + block.length > CTX_CAP) break;
      out += block;
    }
  } catch (e) {
    console.error(`  ! ranked-context gen failed for ${repoUrl}: ${e.message}`);
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
  ctxCache.set(k, out);
  return out;
}

function buildPrompt(task, arm) {
  const head = `Repository: ${task.repoUrl}${task.commit ? ` (work from commit ${task.commit})` : ""}`;
  // Output a diff instead of pushing — Devin has no write access to these
  // upstream repos, so a PR would block. Work fully autonomously.
  const body = `Task: ${task.prompt}\nImplement the change and add a test. Work autonomously without asking for confirmation. In your FINAL message, output the COMPLETE unified diff (git diff format) of every file you created or changed. Do NOT push to GitHub or open a pull request.`;
  if (arm === "A") return `${head}\n\n${body}`;
  // Rank with a focused keyword query, not the verbose task sentence — the full
  // prose dilutes TF-IDF (e.g. rust-analyzer ast.rs: #11 by prose vs #1 by keywords).
  const ctx = sigmapRanked(task.repoUrl, task.query || task.prompt);
  return `${head}\n\nSigMap pre-ranked the most relevant files for this task (function & class signatures — start here instead of exploring the whole repo):\n\n${ctx}\n${body}`;
}

// ── Devin API ────────────────────────────────────────────────────────────────
async function devin(path, init) {
  const res = await fetch(`${DEVIN}${path}`, { ...init, headers: { Authorization: `Bearer ${KEY}`, "Content-Type": "application/json", ...(init?.headers || {}) } });
  if (!res.ok) throw new Error(`Devin ${path} -> ${res.status} ${await res.text().catch(() => "")}`);
  return res.json();
}
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const TERMINAL = new Set(["finished", "blocked", "expired", "suspended", "stopped"]);

/** Best-effort ACU extraction — Devin's field name isn't documented; scan. */
function extractAcus(s) {
  for (const k of ["acu_usage", "acus", "acus_used", "consumed_acus", "compute_units"]) if (typeof s?.[k] === "number") return s[k];
  if (typeof s?.usage?.acus === "number") return s.usage.acus;
  return null;
}

async function runSession(task, arm, rep) {
  const id0 = `${task.id}_${arm}_r${rep}`;
  const t0 = Date.now();
  const created = await devin("/sessions", { method: "POST", body: JSON.stringify({ prompt: buildPrompt(task, arm), idempotent: false, title: `sigmap-exp ${id0}` }) });
  const sid = created.session_id;
  let s = created;
  while (Date.now() - t0 < POLL_MAX_MS) {
    await sleep(15000);
    try { s = await devin(`/session/${sid}`); } catch { continue; }
    if (s.status_enum && TERMINAL.has(s.status_enum)) break;
  }
  writeFileSync(join(SESS_DIR, `${id0}.json`), JSON.stringify(s, null, 2)); // raw for inspection
  const msgs = Array.isArray(s.messages) ? s.messages : [];
  const lastDevin = [...msgs].reverse().find((m) => m.type === "devin_message")?.message || "";
  const hasDiff = /(^|\n)(diff --git|\+\+\+ |@@ )/.test(lastDevin) || /```diff/.test(lastDevin);
  const editedExpected = (task.expected_files || []).some((f) => lastDevin.includes(f) || lastDevin.includes(f.split("/").pop()));
  return {
    task: task.id, arm, rep, sessionId: sid,
    status: s.status_enum || s.status,
    durationMs: Date.now() - t0,
    steps: msgs.length,
    devinMessages: msgs.filter((m) => m.type === "devin_message").length,
    acus: extractAcus(s), // almost always null — Devin's session API omits ACUs
    hasDiff, editedExpected,
    success: hasDiff,
    pr: s.pull_request?.url || s.pull_request || null,
    expectedFiles: task.expected_files || [],
  };
}

// ── Run ──────────────────────────────────────────────────────────────────────
const tasks = readFileSync(TASKS_FILE, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l)).slice(0, MAX);
const resFile = join(OUT, "results.jsonl");
// Merge with any prior results (so re-running one arm doesn't drop the other).
const byKey = new Map(
  (existsSync(resFile) ? readFileSync(resFile, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l)) : [])
    .map((r) => [`${r.task}_${r.arm}_${r.rep}`, r])
);
let results = [...byKey.values()];

if (!REPORT_ONLY) {
  if (!KEY) { console.error("DEVIN_API_KEY required to run sessions."); process.exit(1); }
  console.error(`[devin-exp] ${PILOT ? "PILOT" : "FULL"} · ${tasks.length} tasks × ${ARMS.join("/")} × ${REPS} reps`);
  console.error(`[devin-exp] ⚠ this spends ACUs. Ctrl-C to abort.`);
  for (const task of tasks) for (const arm of ARMS) for (let rep = 1; rep <= REPS; rep++) {
    console.error(`  → ${task.id} arm ${arm} rep ${rep} …`);
    try {
      const r = await runSession(task, arm, rep);
      byKey.set(`${task.id}_${arm}_${rep}`, r);
      results = [...byKey.values()];
      writeFileSync(resFile, results.map((x) => JSON.stringify(x)).join("\n") + "\n");
      console.error(`    ${r.status} · ${(r.durationMs / 60000).toFixed(1)}min · steps ${r.steps} · diff ${r.hasDiff ? "yes" : "no"}`);
    } catch (e) { console.error(`    ✗ ${e.message}`); }
  }
}

// ── Report (paired A vs B) ───────────────────────────────────────────────────
function agg(arm, key) {
  const v = results.filter((r) => r.arm === arm && typeof r[key] === "number").map((r) => r[key]);
  return v.length ? v.reduce((a, b) => a + b, 0) / v.length : null;
}
function saving(key) { const a = agg("A", key), b = agg("B", key); return a && b ? `${(((a - b) / a) * 100).toFixed(1)}%` : "—"; }
const fmt = (n, d = 1) => (n == null ? "—" : n.toFixed(d));

const report = [
  `# Devin Experiment — SigMap impact`,
  ``,
  `Generated ${new Date().toISOString()} · ${results.length} sessions`,
  `Arms: A = no SigMap, B = SigMap context injected. Metrics averaged per arm.`,
  ``,
  `| Metric | A (no SigMap) | B (SigMap) | Saving |`,
  `|---|--:|--:|--:|`,
  `| ACUs / task | ${fmt(agg("A", "acus"))} | ${fmt(agg("B", "acus"))} | ${saving("acus")} |`,
  `| Wall-clock (min) | ${fmt(agg("A", "durationMs") / 60000)} | ${fmt(agg("B", "durationMs") / 60000)} | ${saving("durationMs")} |`,
  `| Steps | ${fmt(agg("A", "steps"))} | ${fmt(agg("B", "steps"))} | ${saving("steps")} |`,
  ``,
  `Success (produced a diff): A ${results.filter((r) => r.arm === "A" && r.success).length}/${results.filter((r) => r.arm === "A").length} · ` +
  `B ${results.filter((r) => r.arm === "B" && r.success).length}/${results.filter((r) => r.arm === "B").length}`,
  `Edited an expected file: A ${results.filter((r) => r.arm === "A" && r.editedExpected).length} · B ${results.filter((r) => r.arm === "B" && r.editedExpected).length}`,
  ``,
  `⚠ ACUs (Devin's billing unit) are NOT returned by the session API — read them`,
  `from the Devin dashboard per session and fill them in. Wall-clock is the only`,
  `auto-captured cost proxy. SigMap's exploration savings show on HARDER tasks in`,
  `LARGER/less-familiar repos — easy tasks in famous repos (flask) show ~no delta.`,
  ``,
].join("\n");
mkdirSync(join(homedir(), "results", "reports"), { recursive: true });
writeFileSync(join(homedir(), "results", "reports", "devin-experiment.md"), report);
console.log(report);
