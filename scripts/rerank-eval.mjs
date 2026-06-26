#!/usr/bin/env node
/**
 * Re-ranker prototype eval — does a better lexical ranker beat SigMap's current
 * TF-IDF on retrieval (hit@5 / MRR)?  For each curated task we take the full
 * candidate set SigMap returns, score it two ways, and compare:
 *   baseline = SigMap's own --query order (TF-IDF)
 *   reranked = BM25 over identifier-split + stemmed tokens, with path-token boost
 *
 * Streams clone -> generate -> eval -> delete (disk-safe). No API/ACU cost.
 * Usage: node scripts/rerank-eval.mjs
 */
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { tmpdir, homedir } from "node:os";

const SIGMAP = join(homedir(), "sigmap", "gen-context.js");
const TASKS_DIR = join(homedir(), "sigmap", "benchmarks", "tasks");
const OUT = join(homedir(), "results", "reports", "rerank-eval.md");

const REPOS = [
  ["akka", "https://github.com/akka/akka"],
  ["axios", "https://github.com/axios/axios"],
  ["express", "https://github.com/expressjs/express"],
  ["fastapi", "https://github.com/tiangolo/fastapi"],
  ["fastify", "https://github.com/fastify/fastify"],
  ["flask", "https://github.com/pallets/flask"],
  ["gin", "https://github.com/gin-gonic/gin"],
  ["laravel", "https://github.com/laravel/framework"],
  ["okhttp", "https://github.com/square/okhttp"],
  ["rails", "https://github.com/rails/rails"],
  ["riverpod", "https://github.com/rrousselGit/riverpod"],
  ["rust-analyzer", "https://github.com/rust-lang/rust-analyzer"],
  ["serilog", "https://github.com/serilog/serilog"],
  ["spring-petclinic", "https://github.com/spring-projects/spring-petclinic"],
  ["svelte", "https://github.com/sveltejs/svelte"],
  ["vapor", "https://github.com/vapor/vapor"],
  ["vue-core", "https://github.com/vuejs/core"],
];

const CONFIG = JSON.stringify({
  srcDirs: ["."], maxDepth: 12, autoMaxTokens: false, maxTokens: 200000, coverageTarget: 0.9,
  exclude: ["node_modules", ".git", "dist", "build", "target", "vendor", "test", "tests",
    "docs", "doc", "website", "i18n", "docusaurus", "locales", "examples", "scripts"],
});

// ── IR re-ranker ─────────────────────────────────────────────────────────────
const STOP = new Set("a an the of to in on for and or is are be by with as at from that this it its into get set add new return value test".split(" "));

/** Light suffix stemmer — conservative, good enough for code identifiers. */
function stem(w) {
  if (w.length <= 3) return w;
  let s = w;
  s = s.replace(/ies$/, "y");
  s = s.replace(/(sses|shes|ches|xes|zes)$/, (m) => m.slice(0, -2));
  s = s.replace(/([^s])s$/, "$1");
  s = s.replace(/(ization|izations)$/, "ize");
  s = s.replace(/(ing|edly|ed| er|ers|ation|ations|ment|ness|ity|ive|able|ible|ize|ise|al)$/, "");
  return s.length >= 3 ? s : w;
}

/** Split on non-alnum AND camelCase/snake_case, lowercase, stem, drop stopwords. */
function tokenize(text) {
  return text
    .replace(/[^A-Za-z0-9]+/g, " ")
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/([A-Z]+)([A-Z][a-z])/g, "$1 $2")
    .toLowerCase()
    .split(/\s+/)
    .filter((t) => t.length > 1 && !STOP.has(t))
    .map(stem)
    .filter(Boolean);
}

const PATH_BOOST = 3; // repeat path tokens so the filename weighs heavily

/** BM25 re-rank of candidates [{file, sigs}] against a query. */
function bm25rank(query, candidates) {
  const k1 = 1.5, b = 0.75;
  const docs = candidates.map((c) => {
    const pathToks = tokenize(c.file);
    const sigToks = tokenize((c.sigs || []).join(" "));
    const toks = [...sigToks];
    for (let i = 0; i < PATH_BOOST; i++) toks.push(...pathToks);
    const tf = new Map();
    for (const t of toks) tf.set(t, (tf.get(t) || 0) + 1);
    return { file: c.file, tf, len: toks.length };
  });
  const N = docs.length || 1;
  const avgdl = docs.reduce((s, d) => s + d.len, 0) / N || 1;
  const df = new Map();
  for (const d of docs) for (const t of d.tf.keys()) df.set(t, (df.get(t) || 0) + 1);
  const qToks = [...new Set(tokenize(query))];
  const scored = docs.map((d) => {
    let score = 0;
    for (const t of qToks) {
      const f = d.tf.get(t);
      if (!f) continue;
      const idf = Math.log(1 + (N - df.get(t) + 0.5) / (df.get(t) + 0.5));
      score += idf * (f * (k1 + 1)) / (f + k1 * (1 - b + (b * d.len) / avgdl));
    }
    return { file: d.file, score };
  });
  return scored.sort((a, b2) => b2.score - a.score);
}

// ── eval helpers ─────────────────────────────────────────────────────────────
const hitAt = (ranked, expected, k) =>
  ranked.slice(0, k).some((r) => expected.includes(r.file || r));
const mrr = (ranked, expected) => {
  for (let i = 0; i < ranked.length; i++)
    if (expected.includes(ranked[i].file || ranked[i])) return 1 / (i + 1);
  return 0;
};

function sigmap(dir, args) {
  return execFileSync(process.execPath, [SIGMAP, ...args], {
    cwd: dir, encoding: "utf8", timeout: 180000, maxBuffer: 128 * 1024 * 1024,
    stdio: ["ignore", "pipe", "ignore"],
  });
}

// ── run ──────────────────────────────────────────────────────────────────────
const rows = [];
let totTasks = 0, baseHit = 0, reHit = 0, baseMrr = 0, reMrr = 0;

for (const [label, url] of REPOS) {
  const taskFile = join(TASKS_DIR, `${label}.jsonl`);
  if (!existsSync(taskFile)) { console.error(`  skip ${label} (no tasks)`); continue; }
  const tasks = readFileSync(taskFile, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l));
  const work = mkdtempSync(join(tmpdir(), `rr-${label}-`));
  const dir = join(work, "r");
  let rb = 0, rr = 0, rbm = 0, rrm = 0, n = 0;
  try {
    console.error(`→ ${label} (${tasks.length} tasks) cloning…`);
    execFileSync("git", ["clone", "--depth", "1", "-q", url, dir], { timeout: 300000, stdio: "ignore" });
    writeFileSync(join(dir, "gen-context.config.json"), CONFIG);
    sigmap(dir, []); // generate
    for (const t of tasks) {
      const expected = t.expected_files || [];
      if (!expected.length) continue;
      let cands = [];
      try {
        cands = JSON.parse(sigmap(dir, ["--query", t.query, "--top", "800", "--json"])).results || [];
      } catch { continue; }
      if (!cands.length) continue;
      n++;
      const bH = hitAt(cands, expected, 5) ? 1 : 0;       // baseline = SigMap order
      const reranked = bm25rank(t.query, cands);
      const rH = hitAt(reranked, expected, 5) ? 1 : 0;    // reranked = BM25
      rb += bH; rr += rH; rbm += mrr(cands, expected); rrm += mrr(reranked, expected);
    }
    rows.push({ label, n, rb, rr, rbm, rrm });
    totTasks += n; baseHit += rb; reHit += rr; baseMrr += rbm; reMrr += rrm;
    console.error(`   ${label}: hit@5 base ${rb}/${n} -> rerank ${rr}/${n}`);
  } catch (e) {
    console.error(`   ✗ ${label}: ${String(e.message).slice(0, 90)}`);
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
}

// ── report ───────────────────────────────────────────────────────────────────
const pct = (x, n) => (n ? ((x / n) * 100).toFixed(1) : "—");
let md = `# Re-ranker prototype eval — BM25 + identifier-split vs SigMap TF-IDF\n\n`;
md += `${totTasks} tasks across ${rows.length} repos.\n\n`;
md += `| Repo | Tasks | hit@5 base | hit@5 rerank | MRR base | MRR rerank |\n|---|--:|--:|--:|--:|--:|\n`;
for (const r of rows)
  md += `| ${r.label} | ${r.n} | ${pct(r.rb, r.n)}% | ${pct(r.rr, r.n)}% | ${(r.rbm / (r.n || 1)).toFixed(3)} | ${(r.rrm / (r.n || 1)).toFixed(3)} |\n`;
md += `| **Overall** | **${totTasks}** | **${pct(baseHit, totTasks)}%** | **${pct(reHit, totTasks)}%** | **${(baseMrr / (totTasks || 1)).toFixed(3)}** | **${(reMrr / (totTasks || 1)).toFixed(3)}** |\n`;
md += `\nBaseline = SigMap's --query (TF-IDF). Rerank = BM25 over camelCase/snake_case-split, stemmed tokens with ${PATH_BOOST}× path-token boost, over the same candidate set.\n`;

writeFileSync(OUT, md);
console.error(`\n=== OVERALL hit@5: ${pct(baseHit, totTasks)}% -> ${pct(reHit, totTasks)}% · MRR ${(baseMrr / (totTasks || 1)).toFixed(3)} -> ${(reMrr / (totTasks || 1)).toFixed(3)} ===`);
console.error(`report: ${OUT}`);
