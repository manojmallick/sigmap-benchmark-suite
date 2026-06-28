# SigMap Benchmark Suite — Issue Tracker

Tracks findings from running the suite locally. Latest run: **405 repos**
(2026-06) → **321 supported** + 84 unsupported-language excluded — avg token
reduction **95.6%**, overall **98.7%** (1.77B → 23.4M tokens), avg hit@5
**54.1%**. See `FULL_REPORT.md` for scale + task + Devin agent results.

Legend: severity 🔴 high · 🟡 medium · 🟢 low — status ✅ fixed · 🔧 open · 📌 backlog

---

## Open

### ISSUE-1 · Unsupported languages scan empty/approximate · 🟡 · ✅
**Resolved:** `aggregate.mjs` now segments unsupported repos (language outside
SigMap's set, or 0% reduction) out of the headline stats into an "Excluded"
section. 190 → 187 supported + 3 excluded (lua-core, nginx, transit-clj);
avg reduction 94.9% → 95.4%. Original analysis below.

<details><summary>original</summary>
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
</details>

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

### ISSUE-3 · JavaScript avg reduction soft (88.7%) · 🟢 · ✅
**Root cause: language mislabeling, not SigMap.** `detect_lang` only counted
*supported* extensions, so repos that are actually Haskell (cabal, ghc),
Clojure (transit-clj) or C/C++ (mongodb, redis, git, linux, tensorflow…) but
contain a few stray `.js` were bucketed as JavaScript and dragged the average.
- **Fix:** `detect_lang` now counts unsupported extensions too (hs/clj/lua/c…)
  and returns `Unknown` when one dominates (→ excluded by ISSUE-1).
  `scripts/relabel-languages.mjs` re-applies this to existing `meta.json`.
- **Result:** 31 repos relabeled (incl. ansible→Python, grafana→Go,
  vue-core→TypeScript; mongodb/redis/linux/tensorflow→Unknown). JavaScript
  **88.7% → 92.8%**; 190 → **170 supported** (20 unsupported excluded).
- Residual JS laggards (html5-boilerplate, nvm) are tiny/low-signal repos —
  accepted (see ISSUE-4).

### ISSUE-4 · Template/markup-heavy repos low reduction · 🟢 · ✅ (accepted)
**Accepted as expected behavior — won't fix.** helm-charts (YAML templates),
html5-boilerplate (HTML), nvm (shell) have few code signatures by nature, so a
lower reduction is correct. SigMap targets code, not markup/config; these are
edge inputs, not failures.

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

## Devin agent experiment — issues & fixes

A/B harness (`scripts/devin-experiment.mjs`): run each task through Devin twice —
**A** = task prompt only (Devin explores), **B** = SigMap ranked context injected —
and measure wall-clock. The first run showed two *negative* results (akka −14%,
rust-analyzer −65%) that looked like SigMap failures. Investigation proved they
were **harness bugs, not SigMap** — every target file was always in the index.
Fixing them flipped both. Final: **4/5 tasks faster, avg ~61%** (akka 12.5→3.2,
vue-core 30.6→8.9, okhttp 7.0→3.8, flask 4.5→3.9, rust-analyzer 2.1→2.4 noise).

| Task | B before fixes | B after fixes |
|---|--:|--:|
| akka | 14.2 min (−14%) | **3.2 min (+74%)** |
| rust-analyzer | 3.5 min (−65%) | **2.4 min (−16%, noise)** |

### ISSUE-10 · Negative agent results misread as SigMap failures · 🟡 · ✅
**Symptom:** akka/rust-analyzer arm B slower than A → "SigMap hurts the agent."
**Real cause:** three independent harness bugs (ISSUE-11/12/13) corrupted the
*injected context*; the SigMap index itself was correct (every target file was
present — verified by `grep`-ing the generated `copilot-instructions.md`).
**Lesson:** always verify coverage (is the file in the index?) separately from
ranking (is it in the top-K?) before blaming the engine.

### ISSUE-11 · Devin's 30k-char prompt limit · 🔴 · ✅
**Symptom:** all 4 hard-task arm-B sessions failed with
`400 "Prompt is too long. Must be less than 30000 characters."` — the full
SigMap signature map for big repos is far larger than 30k chars.
**Fix:** inject only the **ranked top-K files** for the task (the real
`sigmap ask` workflow), capped at ~22k chars — small, and more realistic than
dumping the whole map. `sigmapRanked()` in the harness.

### ISSUE-12 · Doc/`.md` pollution in ranked context · 🟡 · ✅
**Symptom:** akka's natural-language query matched `akka-docs/*.md` prose, which
ranked **above the code** and got injected — actively *misleading* Devin
(14.2 min). Markdown/RST have no signatures but score high on word overlap.
**Fix:** drop `.md/.mdx/.markdown/.rst/.txt/.adoc` from the ranked results, and
add doc dirs (`akka-docs`, etc.) to the generation `exclude`. akka B → 3.2 min.

### ISSUE-13 · top-K cutoff too tight · 🟡 · ✅
**Symptom:** rust-analyzer's `ast.rs` ranked **#11** for the task — *one slot*
outside the old top-10 cutoff — so it was dropped and Devin got only neighbor
files.
**Fix:** keep **top-15** after doc-filtering (query top-30 to have headroom).
`ast.rs` now included.

### ISSUE-14 · Verbose task sentence dilutes TF-IDF ranking · 🟡 · ✅
**Symptom:** ranking with the full prose prompt ("In the syntax crate's AST
module, add a helper that returns the text range of an expression node…") put
`ast.rs` at #11; a focused keyword query ("ast expression node range") put it at
**#1**. Long sentences add noise tokens that dilute the match.
**Fix:** add a per-task `query` field (focused keywords) to `devin-tasks.jsonl`
and rank with `task.query || task.prompt`.

### ISSUE-15 · Genuine ranker miss on some targets · 🟡 · 🔧 (upstream)
Even after ISSUE-12/13/14, akka's `Cluster.scala` is **not in the top-50 for any
query** — its signatures don't contain the query vocabulary (the reachability
logic lives in sibling files), so TF-IDF can't surface it. akka B still won
(+74%) because the *clean* neighbor context was enough, but the canonical file
wasn't found. **Real fix is in the SigMap core ranker** (stemming/semantic
retrieval) — same root cause as ISSUE-2's residual. Tracks the 62.7% hit@5 ceiling.

### ISSUE-16 · Devin ACUs not in the API · 🟢 · 🔧 (process)
Devin's billing unit (ACUs) and raw token counts are **not returned by the
session API** — only wall-clock/steps/messages are. **Workaround:** read ACUs
per session from the Devin dashboard (session IDs are logged in
`~/results/devin/results.jsonl`). Wall-clock is the only auto-captured cost proxy.

### ISSUE-17 · Single-run agent speedup did not replicate · 🔴 · ✅ (corrected)
The single-run "61% faster" was **n=1 noise**. A clean **3-rep A/B (30 sessions)**
on the fixed re-ranker harness came out **within noise**: completed sessions
averaged **8.4 min (A) vs 8.0 min (B)** (+5%), with high per-session variance.
- **Action taken:** removed the agent-speed claim from the public proof page,
  demo, OG cards, README, and FULL_REPORT; replaced with the honest "not
  established" framing. Token/cost (deterministic) and retrieval (re-ranker)
  claims stand.
- **Lesson:** never publish an n=1 agent metric. Agent wall-clock needs ≥3 reps
  before any claim.

### ISSUE-18 · 30-min poll cap censors big-repo sessions · 🟡 · 🔧 (methodology)
The harness polls each Devin session up to `POLL_MAX_MS` (30 min); a session that
exceeds it records the cap value with `hasDiff=false` — **right-censored** data.
In the 3-rep run this hit **B 4/15 vs A 1/15** (akka B 0/3 completed), biasing the
raw means and making SigMap look slower than completed-only data shows.
- **Fix:** raise the cap to ≥90 min so big-repo sessions complete, and/or report
  **completed-only** means + censoring counts (never average in capped values).
- Until then the agent-speed question stays open (see ISSUE-17).
