# Devin Experiment — SigMap impact

Generated 2026-06-27T03:15:59.655Z · 30 sessions
Arms: A = no SigMap, B = SigMap context injected. Metrics averaged per arm.

| Metric | A (no SigMap) | B (SigMap) | Saving |
|---|--:|--:|--:|
| ACUs / task | — | — | — |
| Wall-clock (min) | 9.8 | 17.8 | -81.3% |
| Steps | 2.9 | 2.6 | 11.4% |

Success (produced a diff): A 14/15 · B 11/15
Edited an expected file: A 11 · B 6

⚠ ACUs (Devin's billing unit) are NOT returned by the session API — read them
from the Devin dashboard per session and fill them in. Wall-clock is the only
auto-captured cost proxy. SigMap's exploration savings show on HARDER tasks in
LARGER/less-familiar repos — easy tasks in famous repos (flask) show ~no delta.
