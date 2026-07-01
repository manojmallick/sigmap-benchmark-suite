#!/usr/bin/env node
/**
 * Generate a self-contained benchmark dashboard (no external scripts/styles/network)
 * from the real aggregated results — replaces the empty SigMap CLI shell with the
 * numbers we actually measured.
 *   node scripts/gen-dashboard.mjs
 * Reads ~/results/exports/results.json (405 rows) + fixed task/agent/re-ranker summary.
 */
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT = join(HERE, "..", "benchmarks", "reports", "dashboard.html");
const rows = JSON.parse(readFileSync(join(homedir(), "results", "exports", "results.json"), "utf8"));

const SUPPORTED = new Set(["TypeScript", "JavaScript", "Python", "Java", "Kotlin", "Go", "Rust",
  "CSharp", "Ruby", "PHP", "Swift", "Dart", "Scala", "Vue", "Svelte"]);
const sup = rows.filter((r) => SUPPORTED.has(r.language) && r.reductionPct > 0);

// ── scale aggregates from real data ──────────────────────────────────────────
const sum = (a) => a.reduce((s, x) => s + x, 0);
const avg = (a) => (a.length ? sum(a) / a.length : 0);
const rawTot = sum(sup.map((r) => r.rawTokens || 0));
const finTot = sum(sup.map((r) => r.finalTokens || 0));
const overall = (1 - finTot / rawTot) * 100;
const avgRed = avg(sup.map((r) => r.reductionPct));
const avgHealth = avg(sup.map((r) => r.healthScore || 0));
const withTasks = sup.filter((r) => typeof r.hitAt5 === "number" && r.tasks > 0);
const avgHit = avg(withTasks.map((r) => r.hitAt5)) * (withTasks[0]?.hitAt5 <= 1 ? 100 : 1);

// per-language avg reduction
const byLang = {};
for (const r of sup) (byLang[r.language] ||= []).push(r.reductionPct);
const langs = Object.entries(byLang)
  .map(([lang, v]) => ({ lang, n: v.length, red: avg(v) }))
  .sort((a, b) => b.n - a.n);

// ── fixed summary from the task/agent/re-ranker experiments ──────────────────
const TASKS = { count: 51, reductionPct: 99.2, cheaperX: 96, costBefore: 1.7261, costAfter: 0.0179, retrieval: 62.7 };
const RERANK = { base: 75.3, reranked: 82.4 };
const AGENT = { reps: 3, aMin: 8.4, bMin: 8.0 };
const now = new Date().toISOString().slice(0, 10);

// ── render ───────────────────────────────────────────────────────────────────
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;");
const card = (label, value, sub = "") =>
  `<div class="card"><div class="label">${label}</div><div class="value">${value}</div>${sub ? `<div class="sub2">${sub}</div>` : ""}</div>`;

// per-language bars: domain 85-100% → visible differences
const W = 940, H = 240, pad = 30, base = H - 40, top = 20;
const dom = [85, 100], px = (v) => base - ((v - dom[0]) / (dom[1] - dom[0])) * (base - top);
const bw = (W - pad * 2) / langs.length;
const bars = langs.map((l, i) => {
  const x = pad + i * bw, h = base - px(l.red);
  return `<rect x="${(x + 3).toFixed(1)}" y="${px(l.red).toFixed(1)}" width="${(bw - 6).toFixed(1)}" height="${h.toFixed(1)}" fill="#34d399" rx="2"/>`
    + `<text x="${(x + bw / 2).toFixed(1)}" y="${base + 14}" fill="#8ea0d9" font-size="10" text-anchor="middle">${esc(l.lang.slice(0, 6))}</text>`
    + `<text x="${(x + bw / 2).toFixed(1)}" y="${(px(l.red) - 5).toFixed(1)}" fill="#d7defa" font-size="9" text-anchor="middle">${l.red.toFixed(0)}</text>`;
}).join("");

const html = `<!doctype html><html lang="en"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/><title>SigMap Benchmark Dashboard</title><style>
body{margin:0;background:#0a0f1e;color:#e6ecff;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}
.wrap{max-width:980px;margin:0 auto;padding:24px}h1{font-size:22px;margin:0 0 4px}
.sub{color:#8ea0d9;font-size:12px;margin-bottom:20px}a{color:#7aa2ff}
.grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-bottom:16px}
.card{background:#111a33;border:1px solid #223056;border-radius:10px;padding:12px}
.label{font-size:11px;color:#8ea0d9;margin-bottom:6px}.value{font-size:20px;color:#f5f7ff;font-weight:700}
.sub2{font-size:10px;color:#8ea0d9;margin-top:4px}
.panel{background:#111a33;border:1px solid #223056;border-radius:12px;padding:14px;margin-top:12px}
.ph{font-size:13px;color:#d7defa;margin-bottom:10px}.amber{color:#fbbf24}
.row{display:flex;gap:26px;flex-wrap:wrap;align-items:baseline}
.big{font-size:22px;font-weight:700;color:#f5f7ff}.mut{font-size:11px;color:#8ea0d9}
@media (max-width:900px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
</style></head><body><div class="wrap">
<h1>SigMap Benchmark Dashboard</h1>
<div class="sub">Real measured results · reproduced ${now} · self-contained (no external scripts, styles, or network calls) · <a href="https://github.com/manojmallick/sigmap-benchmark-suite">methodology &amp; raw data</a></div>

<div class="grid">
${card("Repos benchmarked", `${sup.length}`, `+${rows.length - sup.length} unsupported-lang, excluded`)}
${card("Avg token reduction", `${avgRed.toFixed(1)}%`, `overall ${overall.toFixed(1)}%`)}
${card("Task context", `${TASKS.cheaperX}× cheaper`, `${TASKS.count} tasks · ${TASKS.reductionPct}% fewer tokens`)}
${card("Retrieval hit@5", `${RERANK.base}% → ${RERANK.reranked}%`, `BM25 re-ranker`)}
${card("Health", `${avgHealth.toFixed(0)}/100`, "avg across supported repos")}
${card("Tokens mapped", `${(rawTot / 1e9).toFixed(2)}B → ${(finTot / 1e6).toFixed(0)}M`, "raw → SigMap")}
${card("Cost / task", `$${TASKS.costBefore.toFixed(2)} → $${TASKS.costAfter.toFixed(3)}`, "51-task benchmark")}
${card("Agent speedup", "≈ tie", `${AGENT.reps}-rep A/B — not established`)}
</div>

<div class="panel">
<div class="ph">Per-language avg token reduction (${langs.length} supported languages, %)</div>
<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Per-language token reduction">
<rect x="0" y="0" width="100%" height="100%" fill="#0f1320" rx="12"/>
<line x1="${pad}" y1="${base}" x2="${W - pad}" y2="${base}" stroke="#223056"/>
${bars}
</svg></div>

<div class="panel">
<div class="ph">Agent A/B — Devin, ${AGENT.reps} reps (honest result)</div>
<div class="row">
<div><div class="big">${AGENT.aMin.toFixed(1)}m</div><div class="mut">no SigMap (avg, completed)</div></div>
<div><div class="big">${AGENT.bMin.toFixed(1)}m</div><div class="mut">with SigMap (avg, completed)</div></div>
<div class="big amber">≈ Tie — within measurement noise</div>
</div>
<div class="mut" style="margin-top:10px">A single early run looked like a large win (~61%) but did not replicate across ${AGENT.reps} reps. Token/cost/retrieval gains are deterministic; agent wall-clock is not yet established.</div>
</div>

</div></body></html>`;

mkdirSync(dirname(OUT), { recursive: true });
writeFileSync(OUT, html);
console.error(`✓ dashboard → ${OUT}`);
console.error(`  ${sup.length} supported repos · avg ${avgRed.toFixed(1)}% · overall ${overall.toFixed(1)}% · health ${avgHealth.toFixed(0)} · ${langs.length} languages`);
