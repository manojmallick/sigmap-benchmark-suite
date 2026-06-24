#!/usr/bin/env node
/**
 * Run task-benchmark.mjs across every repo that (a) is cloned in ~/repos and
 * (b) has a curated task file in ~/sigmap/benchmarks/tasks/, then consolidate
 * into one report: ~/results/reports/task-benchmark-all.md
 *
 * Usage: GEMINI_API_KEY=... node scripts/task-benchmark-all.mjs [maxTasks] [topK]
 */
import { execFileSync } from "node:child_process";
import { readdirSync, existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HOME = process.env.HOME;
const HERE = dirname(fileURLToPath(import.meta.url));
const TASKS_DIR = join(HOME, "sigmap", "benchmarks", "tasks");
const REPOS_DIR = join(HOME, "repos");
const REPORTS = join(HOME, "results", "reports");
const [maxTasks = "3", topK = "5"] = process.argv.slice(2);
if (!process.env.GEMINI_API_KEY) { console.error("GEMINI_API_KEY required"); process.exit(1); }

// Discover task-repos that are cloned.
const repos = readdirSync(TASKS_DIR)
  .filter((f) => f.endsWith(".jsonl") && f !== "retrieval.jsonl")
  .map((f) => f.replace(/\.jsonl$/, ""))
  .filter((name) => existsSync(join(REPOS_DIR, name)));

console.error(`[all] ${repos.length} task-repos: ${repos.join(", ")}`);

for (const name of repos) {
  console.error(`\n[all] === ${name} ===`);
  try {
    execFileSync(process.execPath, [
      join(HERE, "task-benchmark.mjs"),
      join(REPOS_DIR, name), join(TASKS_DIR, `${name}.jsonl`), maxTasks, topK,
    ], { stdio: ["ignore", "ignore", "inherit"], maxBuffer: 64 * 1024 * 1024 });
  } catch (e) {
    console.error(`[all] ${name} failed: ${e.message}`);
  }
}

// Consolidate sidecars.
const sides = repos
  .map((n) => join(REPORTS, `task-benchmark-${n}.json`))
  .filter(existsSync)
  .map((p) => JSON.parse(readFileSync(p, "utf8")));

const pct = (n) => `${(n * 100).toFixed(1)}%`;
const usd = (n) => `$${n.toFixed(4)}`;
const lang = {}; // fill from results.json if present
try {
  for (const r of JSON.parse(readFileSync(join(HOME, "results", "exports", "results.json"), "utf8")))
    lang[r.repo] = r.language;
} catch {}

const T = (k) => sides.reduce((s, x) => s + (x.totals[k] || 0), 0);
const hits = T("hits"), n = T("n");

const out = [
  `# Task Benchmark — all repos (with vs without SigMap)`,
  ``,
  `Generated: ${new Date().toISOString()} · ${sides.length} repos · ${n} tasks · gemini-2.5-flash`,
  ``,
  `Per task: *without* = whole-repo source, *with* = only the files SigMap ranks.`,
  `Prompt tokens & cost are deterministic; latency is best-of-N.`,
  ``,
  `| Repo | Lang | Tasks | Right file | Without tok | With tok | Reduction | Cheaper |`,
  `|---|---|--:|:--:|--:|--:|--:|--:|`,
  ...sides.map((s) => {
    const t = s.totals;
    const red = t.woTok ? 1 - t.wTok / t.woTok : 0;
    const cheaper = t.wCost ? t.woCost / t.wCost : 0;
    return `| ${s.repo} | ${lang[s.repo] || "—"} | ${t.n} | ${t.hits}/${t.n} | ${t.woTok.toLocaleString()} | ${t.wTok.toLocaleString()} | ${pct(red)} | ${cheaper.toFixed(0)}× |`;
  }),
  ``,
  `| **Overall** | | **${n}** | **${hits}/${n}** | **${T("woTok").toLocaleString()}** | **${T("wTok").toLocaleString()}** | **${pct(1 - T("wTok") / T("woTok"))}** | **${(T("woCost") / T("wCost")).toFixed(0)}×** |`,
  ``,
  `**Totals:** without ${usd(T("woCost"))} · with ${usd(T("wCost"))} · ` +
  `retrieval ${pct(hits / n)} of tasks found the correct file in top-${topK}.`,
  ``,
].join("\n");

writeFileSync(join(REPORTS, "task-benchmark-all.md"), out);
console.log(out);
console.error(`\n[all] written: ${join(REPORTS, "task-benchmark-all.md")}`);
