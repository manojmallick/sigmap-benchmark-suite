# Task Benchmark — all repos (with vs without SigMap)

Generated: 2026-06-24T22:28:57.417Z · 17 repos · 51 tasks · gemini-2.5-flash

Per task: *without* = whole-repo source, *with* = only the files SigMap ranks.
Prompt tokens & cost are deterministic; latency is best-of-N.

| Repo | Lang | Tasks | Right file | Without tok | With tok | Reduction | Cheaper |
|---|---|--:|:--:|--:|--:|--:|--:|
| akka | Scala | 3 | 1/3 | 470,805 | 1,818 | 99.6% | 188× |
| axios | JavaScript | 3 | 1/3 | 144,966 | 3,219 | 97.8% | 37× |
| express | JavaScript | 3 | 3/3 | 58,200 | 1,292 | 97.8% | 30× |
| fastapi | Python | 3 | 1/3 | 481,636 | 2,571 | 99.5% | 149× |
| fastify | JavaScript | 3 | 1/3 | 363,065 | 4,142 | 98.9% | 75× |
| flask | Python | 3 | 3/3 | 270,314 | 5,360 | 98.0% | 45× |
| gin | Go | 3 | 2/3 | 417,106 | 3,918 | 99.1% | 91× |
| laravel | PHP | 3 | 2/3 | 482,894 | 1,408 | 99.7% | 236× |
| okhttp | Kotlin | 3 | 3/3 | 343,656 | 1,448 | 99.6% | 165× |
| rails | Ruby | 3 | 3/3 | 159,171 | 2,166 | 98.6% | 56× |
| riverpod | Dart | 3 | 1/3 | 482,262 | 1,863 | 99.6% | 188× |
| rust-analyzer | Rust | 3 | 3/3 | 524,227 | 3,778 | 99.3% | 118× |
| serilog | CSharp | 3 | 2/3 | 284,001 | 1,853 | 99.3% | 112× |
| spring-petclinic | Java | 3 | 0/3 | 48,511 | 1,725 | 96.4% | 10× |
| svelte | Svelte | 3 | 2/3 | 403,356 | 3,680 | 99.1% | 93× |
| vapor | Swift | 3 | 1/3 | 464,017 | 1,438 | 99.7% | 221× |
| vue-core | TypeScript | 3 | 3/3 | 344,375 | 4,187 | 98.8% | 71× |

| **Overall** | | **51** | **32/51** | **5,742,562** | **45,866** | **99.2%** | **96×** |

**Totals:** without $1.7261 · with $0.0179 · retrieval 62.7% of tasks found the correct file in top-5.
