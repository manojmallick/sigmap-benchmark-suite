# SigMap — Full Benchmark Report

*Locally reproduced, 2026-06. Engine: SigMap v7.30. Three independent
experiments: scale (405 repos), task-level (51 tasks, with/without), and a real
autonomous agent (Devin, A/B).*

---

## Executive summary

| Claim | Result | Confidence |
|---|---|---|
| **Token reduction** | **95.6% avg / 98.7% overall** across 321 supported repos (1.77B → 23.4M tokens) | HIGH (deterministic) |
| **Cost reduction (task context)** | **99.2% fewer tokens, 96× cheaper** ($1.73 → $0.018 over 51 tasks) | HIGH (deterministic) |
| **Retrieval precision** | **62.7% hit@5** (right file in top-5) | HIGH (objective) |
| **Agent time saving (Devin)** | **~39% avg, up to 71%** — but **mixed/noisy** (n=1), gated by retrieval | MED |
| **Quality** | No regression — all task variants produced working diffs | MED |

**Bottom line:** SigMap's *context/cost reduction* is bulletproof and deterministic.
Its *downstream agent benefit* is real where retrieval hits (vue-core −71% time)
but absent/negative where it misses — so the value is gated by ranker precision.

---

## 1. Scale benchmark — 405 repositories

Whole-repo signature extraction across the published dataset, reproduced locally
(streaming clone→benchmark→delete; macOS bash 3.2 compatible).

- **405 processed → 321 supported + 84 excluded** (Clojure/Lua/C/C++/Haskell —
  outside SigMap's ~21 supported languages; segmented for honesty)
- **Avg reduction 95.6% · Overall 98.7%** (1,765,696,549 → 23,427,118 tokens)
- **Health 100/100** across the board

Every supported language sits in a tight **91–98%** band:

| Lang | Repos | Reduction | Lang | Repos | Reduction |
|---|--:|--:|---|--:|--:|
| Python | 80 | 94.8% | C# | 10 | 96.9% |
| TypeScript | 42 | 95.4% | Kotlin | 9 | 95.2% |
| Rust | 38 | 96.9% | Swift | 8 | 98.3% |
| Go | 38 | 96.5% | Dart | 6 | 94.1% |
| JavaScript | 31 | 93.9% | Scala | 4 | 97.1% |
| Java | 25 | 96.6% | Svelte | 2 | 91.4% |
| PHP | 14 | 94.6% | Vue | 1 | 94.9% |
| Ruby | 13 | 96.4% | | | |

→ Reproduces the published ~96% claim. **Solid at scale.**

---

## 2. Task benchmark — with vs without SigMap (51 tasks, 17 repos)

For each task: *without* = whole-repo source; *with* = only the files SigMap
ranks. Tokens are model-reported (deterministic); cost derived.

- **99.2% fewer tokens** (5,742,562 → 45,866)
- **96× cheaper** ($1.73 → $0.018)
- **Retrieval 62.7%** (32/51 found the exact right file in top-5)
- Per-repo reduction **96.4–99.7%** (every repo)

Retrieval is the variable: perfect 3/3 on express/flask/okhttp/rails/rust-analyzer/
vue-core; 0/3 on spring-petclinic (small repo, lexical miss). The token/cost win
is constant; *which* files get surfaced is the limitation.

---

## 3. Devin agent experiment — A/B (5 tasks, paired)

Same task through Devin twice: **A** = task only (Devin explores), **B** = SigMap
ranked context injected. Wall-clock measured; **ACUs are dashboard-only** (not in
Devin's API), raw tokens not exposed by Devin.

| Task | A (no SigMap) | B (SigMap) | Δ time | Why |
|---|--:|--:|--:|---|
| vue-core (large) | 30.6 min | 8.9 min | **+71%** | retrieval hit → skipped exploration |
| okhttp (large) | 7.0 min | 3.8 min | **+46%** | hit |
| flask (easy) | 4.5 min | 3.9 min | +12% | noise (easy/famous) |
| akka (huge) | 12.5 min | 14.2 min | **−14%** | **miss** — target file not ranked |
| rust-analyzer (huge) | 2.1 min | 3.5 min | **−65%** | **miss** — ranked neighbors, not target |
| **Average** | **11.3** | **6.9** | **~39%** | |

**SigMap helps when retrieval hits, hurts when it misses.** On the misses the
injected context (tiny: 1.3–2.8k tokens) pointed Devin at *neighbor* files
(akka: `ClusterEvent` not `Cluster.scala`; rust-analyzer: `ast/traits.rs` not
`ast.rs`) — worse than letting it explore. Every task still produced a working
diff (no quality regression).

**Caveats:** n=1 per cell (Devin is stochastic — needs ≥3 reps for CIs); ACU/cost
not yet captured (read from dashboard); wall-clock only.

---

## Honest limitations

1. **Retrieval precision is the ceiling.** 62.7% hit@5; the TF-IDF ranker finds
   *neighbors, not the target* on some tasks (no stemming/semantics). This gates
   the agent benefit and is fixable only in the SigMap **core** ranker.
2. **Unsupported languages** (Clojure/Lua/C/C++/Haskell) scan empty — 84/405
   excluded; don't claim them.
3. **Devin opacity** — ACUs not API-exposed; agent metrics are wall-clock + (manual) ACUs.
4. **Doc pollution** — natural-language queries can rank `.md` docs over code
   (fixed in the harness by filtering doc files).

## Recommendations

- **Lead with the deterministic numbers** (95–99% token/cost reduction) — they're
  unimpeachable.
- **Invest in the core ranker** (semantic/stemmed retrieval) — it converts the
  retrieval misses into agent wins; it's the single highest-leverage improvement.
- **For the agent claim**, run ≥3 reps + capture dashboard ACUs before publishing.

*Artifacts: `~/results/reports/{report.md, academic_table.md, task-benchmark-all.md,
devin-experiment.md}`, `~/results/exports/results.{csv,json,jsonl}`. Reproduce via
`scripts/run_streaming.mjs`, `task-benchmark-all.mjs`, `devin-experiment.mjs`.*
