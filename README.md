# SigMap Benchmark Suite

Reproducible benchmarks for [SigMap](https://github.com/manojmallick/sigmap), a context engine that gives AI coding agents compact, verified signatures instead of whole source files. The suite measures what that saves, and whether it still finds the right code.

It contains the scripts, the per-repository dataset, and the reports for four experiments. See [What the data supports](#what-the-data-supports) before quoting any number.

## Results at a glance

Reproduced locally with SigMap v7.30 (June 2026). Full detail in [FULL_REPORT.md](FULL_REPORT.md) and the [visual dashboard](https://htmlpreview.github.io/?https://github.com/manojmallick/sigmap-benchmark-suite/blob/main/benchmarks/reports/dashboard.html).

| Experiment | Result | Confidence |
|---|---|---|
| **Scale**: 405 repositories | 95.6% average / 98.7% overall token reduction across the 321 repos in supported languages (1.77 B to 23.4 M tokens). 84 repos in unsupported languages are excluded and reported separately | High (deterministic) |
| **Tasks**: 51 real coding tasks | 99.2% fewer context tokens, 96× cheaper ($1.73 to $0.018); the right file is in the top 5 for 62.7% of tasks | High (deterministic, objective) |
| **Re-ranker**: BM25 prototype | Retrieval hit@5 rises from 75.3% to 82.4% (MRR +16%) over the TF-IDF baseline | Medium (prototype) |
| **Agent**: Devin A/B | **Speedup not established.** A 3-repetition run came out within noise (8.4 vs 8.0 minutes on completed sessions); an earlier single run that looked like a large win did not replicate | Low |

### What the data supports

Token and cost reduction and retrieval accuracy are measured and repeatable. A faster autonomous agent is **not** shown by this data. Please do not cite an agent speed-up from this repository.

## Datasets

All files are in [`data/`](data/), in four formats (CSV, JSON, JSONL, SQL).

| Version | Repos | Files | DOI |
|---|---|---|---|
| Published | 240 | `sigmap-240-repos-published-2026-04-29.*` | [10.5281/zenodo.19898842](https://doi.org/10.5281/zenodo.19898842) |
| Extended | 405 | `sigmap-405-repos-extended-2026-04-29.*` | Not yet published on Zenodo |

Each row describes one repository: name and URL, primary language, file count, estimated lines of code, whether it is a monorepo, raw and final token estimates, `reduction_percent`, tokens per file, compression ratio and timings for each SigMap step. [DATASET_VERSIONS.md](DATASET_VERSIONS.md) explains how the two versions relate. A fresh local reproduction (June 2026) is in `data/local-reproduction-2026-06/`.

## Reproduce it

Requirements: Node.js 18+, git, and a local checkout of SigMap at `~/sigmap` (the scripts call `~/sigmap/gen-context.js`). Results are written under `~/results`.

```bash
git clone https://github.com/manojmallick/sigmap ~/sigmap
git clone https://github.com/manojmallick/sigmap-benchmark-suite
cd sigmap-benchmark-suite
```

| Experiment | Command | Needs |
|---|---|---|
| Quick local run on a small, language-diverse set | `bash scripts/run_local.sh [output-dir]` | git, Node |
| Scale (405 repos, resumable) | `node scripts/run_streaming.mjs [target=405] [repo-list]` | Disk for one clone at a time (each repo is cloned, benchmarked, then deleted) |
| Aggregate raw results into CSV/JSON/reports | `node scripts/aggregate.mjs [rawDir] [outDir]` | Output of the scale run |
| Tasks (with vs without SigMap) | `GEMINI_API_KEY=... node scripts/task-benchmark-all.mjs [maxTasks] [topK]` | Gemini API key; task files in `~/sigmap/benchmarks/tasks/` |
| Re-ranker (TF-IDF vs BM25) | `node scripts/rerank-eval.mjs` | No API cost |
| Agent A/B (Devin) | `DEVIN_API_KEY=... node scripts/devin-experiment.mjs --pilot` | **Spends real Devin ACUs.** `--pilot` runs one task; see [scripts/DEVIN_EXPERIMENT.md](scripts/DEVIN_EXPERIMENT.md) |
| Rebuild the dashboard | `node scripts/gen-dashboard.mjs` | Reports from the runs above |

`scripts/repo-list.txt` lists the repositories (`<git-url> <label>` per line); `scripts/repos-extended.json` holds the extended set. The older `01_setup.sh` to `05_upload_results.sh` scripts target the original Google Cloud VM run and are kept for reference.

## Repository layout

```
data/                      Datasets (240-repo published, 405-repo extended, local reproduction)
scripts/                   Benchmark runners, aggregator, re-ranker, Devin harness, dashboard generator
benchmarks/reports/        Generated dashboard and report index
tasks-extended/            Task files (.jsonl) for the task benchmark
zenodo_submission*/        Metadata, methodology and reproducibility notes for the Zenodo releases
FULL_REPORT.md             Consolidated results of all experiments
issues.md                  Issues found and fixed while reproducing (ISSUE-1 to ISSUE-18)
docs/PROJECT_STATUS.md     Earlier internal status notes, kept for history
docs/promotion/            Publication and announcement drafts (paper submission, release, social posts)
```

## Further reading

- [FULL_REPORT.md](FULL_REPORT.md): results, methods and caveats for each experiment
- [zenodo_submission/METHODOLOGY.md](zenodo_submission/METHODOLOGY.md) and [REPRODUCIBILITY.md](zenodo_submission/REPRODUCIBILITY.md): how the published dataset was produced
- [issues.md](issues.md): every problem hit and how it was resolved
- [SIGMAP_ECOSYSTEM.md](SIGMAP_ECOSYSTEM.md): how SigMap, this suite and the web demo ([sigmap-live](https://github.com/manojmallick/sigmap-live)) fit together

## License

The dataset submission includes its own [LICENSE](zenodo_submission/LICENSE). The repository root has no license file; add one if you want to state terms for the scripts.
