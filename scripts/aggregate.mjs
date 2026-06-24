#!/usr/bin/env node
/**
 * SigMap Benchmark Suite — Aggregator (self-contained, zero-dependency).
 *
 * Replaces the VM-only infrastructure/export_academic_datasets.py. Reads the
 * per-repo JSON written by 03_run_benchmarks.sh and emits machine-readable
 * exports plus human/academic reports.
 *
 * Usage:
 *   node scripts/aggregate.mjs [rawDir] [outDir]
 *   defaults: rawDir=$HOME/results/raw  outDir=$HOME/results
 *
 * Per-repo input (one dir per repo under rawDir), any may be missing:
 *   report.json   (sigmap --report --json)   rawTokens/finalTokens/reductionPct/coverage
 *   health.json   (sigmap --health --json)   score/grade
 *   benchmark.json(sigmap --benchmark --json) tasks/hitAt5/mrr/precisionAt5
 *   analyze.json  (sigmap --analyze --json)   files[]
 *   meta.json                                  repo/language/file_count
 */
import {
  readdirSync,
  readFileSync,
  writeFileSync,
  mkdirSync,
  existsSync,
  statSync,
} from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const RAW_DIR = process.argv[2] || join(homedir(), "results", "raw");
const OUT_DIR = process.argv[3] || join(homedir(), "results");
const EXPORT_DIR = join(OUT_DIR, "exports");
const REPORT_DIR = join(OUT_DIR, "reports");

function readJson(path) {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch {
    return null;
  }
}
function num(v) {
  return typeof v === "number" && Number.isFinite(v) ? v : null;
}
function avg(xs) {
  const v = xs.filter((x) => typeof x === "number" && Number.isFinite(x));
  return v.length ? v.reduce((a, b) => a + b, 0) / v.length : null;
}
function pct(x, d = 1) {
  return x == null ? "—" : `${x.toFixed(d)}%`;
}

if (!existsSync(RAW_DIR)) {
  console.error(`[aggregate] raw dir not found: ${RAW_DIR}`);
  process.exit(1);
}

// ── Collect one row per repo ────────────────────────────────────────────────
const rows = [];
for (const name of readdirSync(RAW_DIR)) {
  const dir = join(RAW_DIR, name);
  if (!statSync(dir).isDirectory()) continue;

  const report = readJson(join(dir, "report.json")) || {};
  const health = readJson(join(dir, "health.json")) || {};
  const bench = readJson(join(dir, "benchmark.json")) || {};
  const meta = readJson(join(dir, "meta.json")) || {};
  const cov = report.coverage || {};

  // benchmark JSON nests metrics under `metrics` (older shapes were flat);
  // accept both, plus several key spellings.
  const bm = bench.metrics || bench;
  const tasks = num(bm.tasks ?? bm.taskCount);
  // Only treat retrieval metrics as real when the repo actually had tasks —
  // otherwise a repo with no task file would report a misleading 0% hit@5.
  const hasTasks = (tasks ?? 0) > 0;
  const hitAt5 = hasTasks ? num(bm.hitAt5 ?? bm["hit@5"] ?? bm.hit5) : null;
  const mrr = hasTasks ? num(bm.mrr ?? bm.MRR) : null;

  rows.push({
    repo: meta.repo || name,
    language: meta.language || "Unknown",
    fileCount: num(meta.file_count) ?? num(report.fileCount),
    rawTokens: num(report.rawTokens ?? report.inputTokens),
    finalTokens: num(report.finalTokens),
    reductionPct: num(report.reductionPct),
    coverageGrade: cov.grade ?? null,
    coveragePct:
      num(cov.includedFiles) != null && num(cov.totalFiles)
        ? (cov.includedFiles / cov.totalFiles) * 100
        : null,
    healthScore: num(health.score),
    healthGrade: health.grade ?? null,
    hitAt5: hitAt5 != null ? hitAt5 * (hitAt5 <= 1 ? 100 : 1) : null,
    mrr,
    tasks,
  });
}

rows.sort((a, b) => a.repo.localeCompare(b.repo));
mkdirSync(EXPORT_DIR, { recursive: true });
mkdirSync(REPORT_DIR, { recursive: true });

// ── Exports: JSON / JSONL / CSV ─────────────────────────────────────────────
writeFileSync(join(EXPORT_DIR, "results.json"), JSON.stringify(rows, null, 2));
writeFileSync(
  join(EXPORT_DIR, "results.jsonl"),
  rows.map((r) => JSON.stringify(r)).join("\n") + "\n"
);
const cols = [
  "repo", "language", "fileCount", "rawTokens", "finalTokens",
  "reductionPct", "coverageGrade", "coveragePct", "healthScore",
  "healthGrade", "hitAt5", "mrr", "tasks",
];
const csv = [
  cols.join(","),
  ...rows.map((r) =>
    cols.map((c) => (r[c] == null ? "" : String(r[c]))).join(",")
  ),
].join("\n");
writeFileSync(join(EXPORT_DIR, "results.csv"), csv + "\n");

// ── Segment unsupported languages (ISSUE-1) ─────────────────────────────────
// SigMap supports a fixed language set; repos outside it (Clojure/Lua/C…) scan
// empty or sparse and would distort the averages. Keep them out of the
// headline stats and list them separately.
const SUPPORTED = new Set([
  "TypeScript", "JavaScript", "Python", "Java", "Kotlin", "Ruby", "PHP",
  "Swift", "Scala", "Go", "Rust", "CSharp", "Vue", "Svelte", "Dart",
  "HTML_CSS", "CSS", "SCSS", "Shell", "Dockerfile", "YAML_Mixed",
]);
const isSupported = (r) => SUPPORTED.has(r.language) && (r.reductionPct || 0) > 0;
const supported = rows.filter(isSupported);
const unsupported = rows.filter((r) => !isSupported(r));

// ── Per-language aggregation (supported only) ───────────────────────────────
const byLang = new Map();
for (const r of supported) {
  if (!byLang.has(r.language)) byLang.set(r.language, []);
  byLang.get(r.language).push(r);
}
const langRows = [...byLang.entries()]
  .map(([language, rs]) => ({
    language,
    repos: rs.length,
    avgReduction: avg(rs.map((r) => r.reductionPct)),
    avgCoverage: avg(rs.map((r) => r.coveragePct)),
    avgHealth: avg(rs.map((r) => r.healthScore)),
    avgHitAt5: avg(rs.map((r) => r.hitAt5)),
  }))
  .sort((a, b) => b.repos - a.repos);

// ── Overall (supported only) ─────────────────────────────────────────────────
const totalRaw = supported.reduce((s, r) => s + (r.rawTokens || 0), 0);
const totalFinal = supported.reduce((s, r) => s + (r.finalTokens || 0), 0);
const overallReduction = totalRaw ? (1 - totalFinal / totalRaw) * 100 : null;
const stamp = new Date().toISOString();

// ── report.md ───────────────────────────────────────────────────────────────
const report = [
  `# SigMap Benchmark — Summary`,
  ``,
  `Generated: ${stamp}`,
  ``,
  `- Repositories: **${supported.length}** supported` +
    (unsupported.length ? ` (+${unsupported.length} unsupported-language, excluded)` : ""),
  `- Avg token reduction: **${pct(avg(supported.map((r) => r.reductionPct)))}**`,
  `- Overall token reduction: **${pct(overallReduction)}** (${totalRaw.toLocaleString()} → ${totalFinal.toLocaleString()} tokens)`,
  `- Avg coverage: **${pct(avg(supported.map((r) => r.coveragePct)))}**`,
  `- Avg health: **${(avg(supported.map((r) => r.healthScore)) ?? 0).toFixed(0)}/100**`,
  `- Avg hit@5: **${pct(avg(supported.map((r) => r.hitAt5)))}**`,
  ``,
  `## Per repository`,
  ``,
  `| Repo | Lang | Files | Raw | Mapped | Reduction | Coverage | Health |`,
  `|---|---|--:|--:|--:|--:|--:|--:|`,
  ...supported.map(
    (r) =>
      `| ${r.repo} | ${r.language} | ${r.fileCount ?? "—"} | ${r.rawTokens ?? "—"} | ${r.finalTokens ?? "—"} | ${pct(r.reductionPct)} | ${r.coverageGrade ?? "—"} ${r.coveragePct != null ? `(${r.coveragePct.toFixed(0)}%)` : ""} | ${r.healthScore ?? "—"}${r.healthGrade ?? ""} |`
  ),
  ``,
  ...(unsupported.length
    ? [
        `## Excluded — unsupported language / unscannable (${unsupported.length})`,
        ``,
        `Outside SigMap's supported language set, so excluded from the stats above.`,
        ``,
        ...unsupported.map((r) => `- ${r.repo} (${r.language}, reduction ${pct(r.reductionPct)})`),
        ``,
      ]
    : []),
].join("\n");
writeFileSync(join(REPORT_DIR, "report.md"), report);

// ── academic_table.md (per-language, paper-ready) ───────────────────────────
const academic = [
  `# SigMap Benchmark — Results by Language`,
  ``,
  `Generated: ${stamp} · ${supported.length} supported repositories` +
    (unsupported.length ? ` (${unsupported.length} unsupported-language excluded)` : ""),
  ``,
  `| Language | Repos | Avg Token Reduction | Avg Coverage | Avg Health | Avg hit@5 |`,
  `|---|--:|--:|--:|--:|--:|`,
  ...langRows.map(
    (l) =>
      `| ${l.language} | ${l.repos} | ${pct(l.avgReduction)} | ${pct(l.avgCoverage)} | ${(l.avgHealth ?? 0).toFixed(0)} | ${pct(l.avgHitAt5)} |`
  ),
  ``,
  `| **Overall** | **${supported.length}** | **${pct(overallReduction)}** | — | — | **${pct(avg(supported.map((r) => r.hitAt5)))}** |`,
  ``,
].join("\n");
writeFileSync(join(REPORT_DIR, "academic_table.md"), academic);

console.log(`[aggregate] ${rows.length} repos (${supported.length} supported, ${unsupported.length} excluded)`);
console.log(`[aggregate] exports → ${EXPORT_DIR} (results.{csv,json,jsonl})`);
console.log(`[aggregate] reports → ${REPORT_DIR} (report.md, academic_table.md)`);
console.log(
  `[aggregate] overall reduction ${pct(overallReduction)} · avg ${pct(avg(supported.map((r) => r.reductionPct)))}`
);
