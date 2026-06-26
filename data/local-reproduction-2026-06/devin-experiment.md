# Devin Experiment — SigMap impact

Generated 2026-06-26T05:53:14.588Z · 10 sessions
Arms: A = no SigMap, B = SigMap context injected. Metrics averaged per arm.

| Metric | A (no SigMap) | B (SigMap) | Saving |
|---|--:|--:|--:|
| ACUs / task | — | — | — |
| Wall-clock (min) | 11.3 | 6.9 | 39.4% |
| Steps | 3.0 | 3.0 | 0.0% |

Success (produced a diff): A 5/5 · B 5/5
Edited an expected file: A 4 · B 4

⚠ ACUs (Devin's billing unit) are NOT returned by the session API — read them
from the Devin dashboard per session and fill them in. Wall-clock is the only
auto-captured cost proxy. SigMap's exploration savings show on HARDER tasks in
LARGER/less-familiar repos — easy tasks in famous repos (flask) show ~no delta.
