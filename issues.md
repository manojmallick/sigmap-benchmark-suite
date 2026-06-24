# SigMap Benchmark Suite — Issue Tracker

Tracks findings from running the suite locally. Latest run: **190 repos**
(2026-06-23) — overall token reduction **99.2%** (1.59B → 12.8M tokens), avg
**94.9%**, scan success **189/190 = 99.5%**, avg hit@5 **54.1%** (17 task-repos).

Legend: severity 🔴 high · 🟡 medium · 🟢 low — status ✅ fixed · 🔧 open · 📌 backlog

---

## Open

### ISSUE-1 · Unsupported languages scan empty/approximate · 🟡 · 🔧
SigMap supports ~21 languages; repos outside that set don't extract real
signatures.
- **transit-clj** (Clojure) → 0% reduction (the only hard scan failure in 190).
- **lua-core** (Lua), **nginx** (C) → detected as `Unknown`, scanned via
  whole-tree fallback, report ~97% but signatures are sparse → numbers are
  approximate, not representative.
- **Impact:** 3 / 190 repos. Distorts a few rows.
- **Fix options:** (a) exclude unsupported-language repos from the run; or
  (b) add a `supported_language` flag in `meta.json` and have `aggregate.mjs`
  mark/segment them. Decision pending.

### ISSUE-2 · hit@5 = 0% on laravel/riverpod · 🟡 · ✅
Two distinct non-ranker causes (verified):
- **laravel — wrong repo.** Tasks target `src/Illuminate/...` (laravel/**framework**)
  but the suite cloned laravel/**laravel** (the app skeleton); expected files
  don't exist there. Fixed: `02_clone_repos.sh` now uses `laravel/framework`.
  → retrieval 0/3 → **2/3**.
- **riverpod — docs pollution.** Expected file existed but the top-5 were all
  `website/i18n/.../*.dart` Docusaurus examples crowding it out. Fixed: excludes
  now drop `website/i18n/docusaurus/locales/docs/examples` for every config.
  → retrieval 0/3 → **1/3**.
- **Also fixed a task-benchmark bug:** `rawSource()` EXT list was missing
  `.dart/.vue/.svelte`, so the "without" baseline for those languages was empty
  (or counted doc `.ts`). Now included → correct baselines.
- **Residual:** laravel-t002, riverpod-t002/t003 still miss — genuine TF-IDF
  lexical misses (query shares no tokens with the signatures). Ranker
  limitation, not config; would need stemming/semantic ranking upstream.

### ISSUE-3 · JavaScript avg reduction soft (88.7%) · 🟢 · 🔧
JavaScript is the lowest language band (19 repos, 88.7%) vs 94–98% elsewhere.
- **Suspected cause:** a few JS repos heavy on bundled/minified/vendored or
  config files diluting signal.
- **Fix:** spot-check the lowest JS repos (`results/exports/results.csv`),
  tighten `exclude` (dist/vendor/min.js) if confirmed.

### ISSUE-4 · Template/markup-heavy repos low reduction · 🟢 · 📌
Expected, low priority (few code signatures by nature):
- **helm-charts** 53.9% (YAML templates), **html5-boilerplate** 64.4% (HTML).
- **Decision:** likely accept as-is; optionally note in the report that
  markup/config repos are not the target use case.

---

## Resolved

### ISSUE-5 · JVM multi-module repos scanned 0 files · 🔴 · ✅
spring-boot, elasticsearch, kafka, akka, kotlin-lang, ktor, retrofit, spark
all reported 0% — source lives in `<module>/src/main/...` but `srcDirs` only
matched top-level. Dragged avg reduction to 82.5% and zeroed Java/Scala/Kotlin
rows.
- **Fix:** scan whole tree (`srcDirs ["."]`) for JVM langs in
  `03_run_benchmarks.sh`. Recovered all 8 (Java 0→97%, Scala 0→98%,
  Kotlin 30→96%); avg reduction 82.5% → 95%.

### ISSUE-6 · Suite not runnable outside GCP VM · 🔴 · ✅
`run_all.sh` referenced non-existent `01_setup_vm.sh` /
`04_aggregate_results.js`; real aggregator was in a missing `infrastructure/`.
- **Fix:** added self-contained `scripts/aggregate.mjs`, `scripts/01_setup.sh`,
  `scripts/run_local.sh`; rewired `run_all.sh`.

### ISSUE-7 · macOS bash 3.2 incompatibilities · 🔴 · ✅
`run_all.sh` died at step 3 on macOS.
- `declare -A LANG_MAP` (bash 4+) → `lang_of()` case function.
- `date +%s%3N` (GNU only; BSD emits literal `3N`) → portable `now_ms()`.

### ISSUE-8 · hit@5 not measured / misreported · 🔴 · ✅
- Curated tasks weren't dropped into repos → no retrieval scoring.
- Aggregator read flat `hitAt5` (it's nested under `metrics`).
- Repos without tasks showed a misleading 0% instead of `—`.
- **Fix:** copy `sigmap/benchmarks/tasks/<repo>.jsonl` →
  `benchmarks/tasks/retrieval.jsonl` + high-coverage generation; aggregator
  reads `metrics.{hitAt5,mrr,tasks}` and treats no-task repos as `—`.

### ISSUE-9 · Arbitrary/extended repos grouped as Unknown · 🟡 · ✅
Repos outside the hardcoded label map had no language → wrong config.
- **Fix:** `detect_lang()` infers language by dominant source extension;
  `Unknown` falls back to whole-tree scan.

---

## Task benchmark (end-to-end proof)

`scripts/task-benchmark.mjs` answers real coding tasks (from the curated task
files) two ways and measures deterministic tokens/cost + best-of-N latency +
retrieval correctness + groundedness:

```bash
GEMINI_API_KEY=... node scripts/task-benchmark.mjs ~/repos/flask \
  ~/sigmap/benchmarks/tasks/flask.jsonl 3 5
```

Proof (gemini-2.5-flash, temp 0):
- **flask:** without 90k tok/$0.027/task → with SigMap ~2k → **97.8% fewer
  tokens, 40× cheaper, 3/3 right file**.
- **gin:** without 208k → with ~1.3k → **99.4% fewer tokens, 137× cheaper,
  2/3 right file** (gin-t002 = lexical-match miss, see ISSUE-2).

Prompt tokens are deterministic (reported by the model); cost is derived;
latency is best-of-N (LLM timing is inherently noisy). Token/cost/retrieval
are the rock-solid proof; time is a softer (still favorable) signal that grows
with repo size.

## How to reproduce

```bash
# local, small (10 repos, ~2 min)
bash scripts/run_local.sh

# full pipeline (clones repo list → benchmark → aggregate)
bash scripts/run_all.sh

# re-aggregate existing raw results
node scripts/aggregate.mjs ~/results/raw ~/results
```
Outputs: `~/results/reports/{report.md,academic_table.md}` ·
`~/results/exports/results.{csv,json,jsonl}`
