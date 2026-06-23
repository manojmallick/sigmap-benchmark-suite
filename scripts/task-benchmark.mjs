#!/usr/bin/env node
/**
 * Task benchmark — deterministic proof that SigMap helps on real coding tasks.
 *
 * For each task (a natural-language request + the files that must be edited),
 * answer it two ways and measure:
 *   WITHOUT SigMap : feed the whole repo source  (you don't know which file)
 *   WITH SigMap    : feed only the files SigMap ranks for the task
 * Metrics: prompt tokens (deterministic, from the model), cost (deterministic),
 * latency (best-of-N to denoise), whether the right file was retrieved
 * (deterministic), and groundedness of the WITH answer (sigmap judge).
 *
 * Usage:
 *   GEMINI_API_KEY=... node scripts/task-benchmark.mjs <repoPath> <tasksFile> [maxTasks] [topK]
 */
import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync, mkdtempSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";

const SIGMAP = join(process.env.HOME, "sigmap", "gen-context.js");
const [repoPath, tasksFile, maxTasksArg, topKArg] = process.argv.slice(2);
const MAX_TASKS = Number(maxTasksArg || 3);
const TOP_K = Number(topKArg || 5);
const SAMPLES = 2; // best-of-N for latency denoise
const MODEL = "gemini-2.5-flash";
const RAW_CAP = 600_000; // chars of raw source for the "without" baseline
const KEY = process.env.GEMINI_API_KEY;
if (!repoPath || !tasksFile || !KEY) {
  console.error("usage: GEMINI_API_KEY=... node task-benchmark.mjs <repo> <tasks.jsonl> [maxTasks] [topK]");
  process.exit(1);
}

const IN = 0.3 / 1e6, OUT = 2.5 / 1e6; // gemini-2.5-flash $/token
const usd = (t) => `$${t.toFixed(4)}`;

function sh(args) {
  return execFileSync(process.execPath, [SIGMAP, ...args], {
    cwd: repoPath, encoding: "utf8", maxBuffer: 64 * 1024 * 1024,
  });
}

/** Concatenate raw source (the "without SigMap" baseline), capped. */
function rawSource() {
  const SKIP = /(^|\/)(node_modules|\.git|dist|build|out|target|test|tests|__tests__|docs|examples)\//;
  const EXT = /\.(js|mjs|cjs|jsx|ts|tsx|py|go|rb|java|kt|rs|cs|php|swift|scala)$/i;
  let text = "";
  const walk = (dir, rel = "") => {
    if (text.length > RAW_CAP) return;
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const r = rel ? `${rel}/${e.name}` : e.name;
      if (SKIP.test(`/${r}/`)) continue;
      const full = join(dir, e.name);
      if (e.isDirectory()) walk(full, r);
      else if (EXT.test(e.name)) {
        try {
          const body = readFileSync(full, "utf8");
          if (text.length + body.length < RAW_CAP) text += `\n// ${r}\n${body}`;
        } catch {}
      }
    }
  };
  walk(repoPath);
  return text;
}

async function gemini(context, task) {
  const prompt = `You are editing this codebase. Task: ${task}\n\nAvailable context:\n${context}\n\nName the exact file(s) and function(s) to change, how, and what tests to add. Be specific.`;
  let best = null;
  for (let i = 0; i < SAMPLES; i++) {
    const t0 = Date.now();
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`,
      { method: "POST", headers: { "Content-Type": "application/json", "x-goog-api-key": KEY },
        body: JSON.stringify({ contents: [{ role: "user", parts: [{ text: prompt }] }], generationConfig: { temperature: 0, maxOutputTokens: 700 } }) }
    );
    const ms = Date.now() - t0;
    const d = await res.json();
    const u = d.usageMetadata || {};
    const answer = (d.candidates?.[0]?.content?.parts || []).map((p) => p.text || "").join("");
    const cur = { ms, promptTokens: u.promptTokenCount || 0, outTokens: u.candidatesTokenCount || 0, answer };
    if (!best || cur.ms < best.ms) best = cur;
  }
  best.cost = best.promptTokens * IN + best.outTokens * OUT;
  return best;
}

function judge(contextMd, answer) {
  const dir = mkdtempSync(join(tmpdir(), "tb-"));
  writeFileSync(join(dir, "c.md"), contextMd);
  writeFileSync(join(dir, "r.txt"), answer);
  try {
    const out = execFileSync(process.execPath, [SIGMAP, "judge", "--response", join(dir, "r.txt"), "--context", join(dir, "c.md"), "--json"], { encoding: "utf8" });
    return JSON.parse(out.trim().split("\n").pop());
  } catch (e) {
    try { return JSON.parse(String(e.stdout).trim().split("\n").pop()); } catch { return { score: null }; }
  }
}

// ── Run ──────────────────────────────────────────────────────────────────────
sh([]); // generate context once
const raw = rawSource();
const tasks = readFileSync(tasksFile, "utf8").trim().split("\n").map((l) => JSON.parse(l)).slice(0, MAX_TASKS);

const rows = [];
for (const t of tasks) {
  const q = t.query;
  const ranked = JSON.parse(sh(["--query", q, "--top", String(TOP_K), "--json"])).results || [];
  const topFiles = ranked.map((r) => r.file);
  const hit = (t.expected_files || []).some((f) => topFiles.includes(f));
  const withCtx = ranked.map((r) => `// ${r.file}\n${r.sigs.join("\n")}`).join("\n\n");

  process.stderr.write(`  • ${t.id || q.slice(0, 40)} …\n`);
  const wo = await gemini(raw, q);
  const w = await gemini(withCtx, q);
  const g = judge(withCtx, w.answer);

  rows.push({
    id: t.id || q.slice(0, 30), query: q, hit,
    woTok: wo.promptTokens, wTok: w.promptTokens,
    woMs: wo.ms, wMs: w.ms, woCost: wo.cost, wCost: w.cost,
    reduction: wo.promptTokens ? 1 - w.promptTokens / wo.promptTokens : 0,
    grounded: g.score,
  });
}

const sum = (k) => rows.reduce((s, r) => s + (r[k] || 0), 0);
const lines = [
  `# Task Benchmark — ${repoPath.split("/").pop()}`,
  ``,
  `Model: ${MODEL} · temp 0 · latency = best of ${SAMPLES} · prompt tokens are deterministic (from the model).`,
  ``,
  `| Task | Found right file? | Without: tokens / time / cost | With SigMap: tokens / time / cost | Token reduction | Grounded |`,
  `|---|:--:|--:|--:|--:|--:|`,
  ...rows.map((r) =>
    `| ${r.id} | ${r.hit ? "✅" : "❌"} | ${r.woTok} / ${(r.woMs/1000).toFixed(1)}s / ${usd(r.woCost)} | ${r.wTok} / ${(r.wMs/1000).toFixed(1)}s / ${usd(r.wCost)} | ${(r.reduction*100).toFixed(1)}% | ${r.grounded != null ? Math.round(r.grounded*100)+"%" : "—"} |`),
  ``,
  `**Totals:** without ${sum("woTok").toLocaleString()} tok / ${usd(sum("woCost"))} · with ${sum("wTok").toLocaleString()} tok / ${usd(sum("wCost"))} · ` +
  `**${((1 - sum("wTok")/sum("woTok"))*100).toFixed(1)}% fewer tokens, ${(sum("woCost")/sum("wCost")).toFixed(0)}× cheaper** · ` +
  `retrieval ${rows.filter(r=>r.hit).length}/${rows.length} found the right file.`,
  ``,
].join("\n");

const outFile = join(process.env.HOME, "results", "reports", `task-benchmark-${repoPath.split("/").pop()}.md`);
writeFileSync(outFile, lines);
console.log(lines);
console.error(`\n[task-bench] written: ${outFile}`);
