# Devin Experiment — measure SigMap's impact on a real agent

Runs the same coding task through Devin **twice** (prompt-injection A/B) and
measures the deltas:

- **A (control):** task prompt only — Devin explores the repo itself.
- **B (treatment):** SigMap signature map injected, then the same task.

## Metrics
| Measured (from Devin) | Honest note |
|---|---|
| **ACUs / task** | Devin's billing unit = your real cost. Raw tokens are **not** exposed. |
| **Wall-clock** | session duration |
| **Steps** | message/action count in the session |
| **Success** | PR opened (Tier 1); test goes green (Tier 2) |

Separately, the **context tokens we feed** (whole repo vs SigMap map) is
deterministic (~97% fewer) — report it apart from Devin's ACU/time deltas.

## ⚠️ Costs ACUs
Every session spends ACUs from your Devin Max budget. **Always pilot first** to
calibrate ACUs/session before a full run.

## Run
```bash
# 1. Pilot — 1 task, both arms, 1 rep (≈2 sessions) to calibrate ACUs
DEVIN_API_KEY=... node scripts/devin-experiment.mjs --pilot

# 2. Inspect ACU field (Devin's name isn't documented)
cat ~/results/devin/sessions/*.json | grep -i acu     # find the real field

# 3. Full run — N tasks × A/B × reps
DEVIN_API_KEY=... node scripts/devin-experiment.mjs --reps 3 --max 12

# re-aggregate without spending ACUs
node scripts/devin-experiment.mjs --report-only
```

Outputs: `~/results/devin/results.jsonl`, `~/results/devin/sessions/*.json`
(raw), `~/results/reports/devin-experiment.md`.

## Method (keep it rigorous)
- Pre-register the task list (`devin-tasks.jsonl`) before running.
- Pin `commit` per task so both arms see identical code.
- Run ≥3 reps/arm (Devin is stochastic); report variance, ties, and failures.
- Tier 2: add a known-failing test per task and a `testCmd`; success = it
  passes on Devin's PR branch.

## Budget math (fill after pilot)
`sessions = tasks × arms × reps`. e.g. 12 × 2 × 3 = 72 sessions ×
(ACUs/session from pilot) = projected ACUs — check against the monthly cap
before launching.
