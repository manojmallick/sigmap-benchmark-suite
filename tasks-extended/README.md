# Labeled retrieval tasks — how to scale the ranker benchmark

The only honest way to measure SigMap's ranker (exact-token TF-IDF vs the shipped
identifier-aware BM25) is against **human-written natural-language queries with
known target files**. Synthetic label-free queries (a symbol copied out of the
target file) are biased toward exact match and *understate* BM25 — don't use them
to judge ranking quality.

This directory holds those labeled tasks. Add more repos → get a bigger, more
credible benchmark.

## Task file format

One `<repo>.jsonl` per repo. Each line:

```json
{"id": "dplyr-x1", "query": "keep only rows that satisfy a logical condition", "expected_files": ["R/filter.R"]}
```

- **query** — how a *developer* would describe the intent, in plain language.
  Do **not** paste the file's function/class name verbatim (that trivially
  matches exact-token TF-IDF and tests nothing). Describe the behavior.
- **expected_files** — one or more repo-relative paths. A task is a *hit* if any
  of them appears in the ranked top-k. Paths must match the `### <path>` headers
  in the repo's generated `.github/copilot-instructions.md`.

### Authoring checklist
1. Generate context once: in the repo, `node ~/sigmap/gen-context.js` (or clone-mode below).
2. List the indexed files: `grep '^### ' .github/copilot-instructions.md`.
3. Pick a file with a clear single purpose; write 1–2 sentences of *intent* as the query.
4. Verify every `expected_files` path exists as a `### ` header (the runner treats
   a missing path as an automatic miss).
5. Aim for 5 tasks/repo across different subsystems.

## Running

```bash
# Score against already-generated context (fast, no network).
# Reads ~/sigmap/benchmarks/repos/<repo>/.github/copilot-instructions.md by default.
node scripts/rerank-labeled-eval.mjs --tasks-dir tasks-extended

# Only some repos
node scripts/rerank-labeled-eval.mjs --tasks-dir tasks-extended --repos dplyr,ggplot2

# Fresh clone + generate + score + delete (disk-safe streaming). Needs a manifest
# mapping repo -> github url (scripts/repos-extended.json).
node scripts/rerank-labeled-eval.mjs --tasks-dir tasks-extended --clone --manifest scripts/repos-extended.json
```

Output is per-repo and overall **hit@1 / hit@5 / MRR**, TF-IDF vs shipped BM25.

## Adding a new repo (end to end)
1. Add `"<repo>": "https://github.com/org/repo"` to `scripts/repos-extended.json`.
2. Write `tasks-extended/<repo>.jsonl` (5 tasks, per the format above).
3. Run with `--clone --repos <repo>` to clone, generate, and score in one shot.

## Scaling further with an LLM (optional)
To generate candidate tasks at volume, feed a repo's `copilot-instructions.md`
(signatures grouped by file) to an LLM and ask for *intent* queries + the target
file, then **human-review** each — never ship LLM labels unchecked, and reject any
query that just restates a symbol name. The runner and format are unchanged.

## Results so far (shipped BM25 vs old TF-IDF, reused context)

| Set | Repos | Tasks | hit@5 TF-IDF → BM25 |
|---|--:|--:|--:|
| Original benchmark | 18 | 90 | 63.3% → **76.7%** |
| Batch 1 — R language (dplyr, ggplot2, shiny) | 3 | 15 | 73.3% → **86.7%** |
| Batch 2 — Go/TS/Py/Java/Rust (cobra, echo, zod, click, httpx, retrofit, clap) | 7 | 35 | 77.1% → **88.6%** |
| Batch 3 — C#/Swift/Ruby/PHP/C++/Kotlin/Scala (polly, alamofire, sidekiq, guzzle, fmt, kotlinx-coroutines, upickle) | 7 | 35 | 68.6% → **77.1%** |
| Batch 4 — Dart/C/Go/TS/Py/Java/C++ (dio, libuv, gorm, zustand, rich, gson, spdlog) | 7 | 35 | 62.9% → **82.9%** |
| **Combined** | **42** | **210** | **67.1% → 80.5%** |

Combined hit@1 41.9% → **53.3%**, MRR 0.538 → **0.651**. Positive on every batch.
Per-repo regressions to date: `upickle` 80→20 and `clap`/`gorm` −1 task (path-boost
flooding on repeated path tokens — see note below). All washed out at aggregate.

**Per-repo "regressions" — investigated; NOT a ranker bug (negative result):**
We prototyped four path-boost fixes (lower boost 3→2, distinct path tokens,
basename-dedup, and combinations) and A/B'd them across all 210 tasks. Findings:
- **`gorm` −1 task was a *label bug*** — the repo has two `migrator.go` (root +
  `migrator/`); the ranker correctly returned the subpackage one. Fixed the label →
  gorm back to 100%.
- **`upickle` (20%) and `clap` (80%) are query-vocabulary cases, not path-boost defects.**
  e.g. upickle-x1's query *"JSON **AST** value types…"* legitimately matches
  `AstTransformer.scala` (rare high-IDF "ast") and `WebJson.scala` ("json") better than
  the terse target `Value.scala`; clap's query *"**argument**…"* stems to `argu`, which
  never matches the file `arg.rs`. The ranker's answers are defensible given those queries.
- **No path-boost tweak helped the aggregate.** boost-2 was noise (+0.4pt), and
  **basename-dedup *hurt* recall (−1.5pt)**. Path-boost is net-positive; we did **not**
  change the shipped ranker. (The truly duplicate-name flood, e.g. `WebJson.scala`, is a
  display-dedup UX question, not a recall fix — dedup lowers hit@5.)

Net: the only real defect was one mislabeled task. Investigation saved us from shipping
a harmful "fix." Combined hit@5 after the label fix: **81.0%**.

Batch 2 repos needed explicit `srcDirs` (auto-detect grabbed `doc/`, `tests/`,
`website/` javadoc): cobra/echo `["."]`, click `["src/click"]`, httpx `["httpx"]`,
retrofit `["retrofit/src/main/java"]`, clap default. Set these in the repo's
`gen-context.config.json` before generating, or the index won't contain the source.
