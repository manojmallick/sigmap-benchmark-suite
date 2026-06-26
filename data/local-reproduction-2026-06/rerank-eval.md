# Re-ranker prototype eval — BM25 + identifier-split vs SigMap TF-IDF

85 tasks across 17 repos.

| Repo | Tasks | hit@5 base | hit@5 rerank | MRR base | MRR rerank |
|---|--:|--:|--:|--:|--:|
| akka | 5 | 60.0% | 60.0% | 0.469 | 0.463 |
| axios | 5 | 60.0% | 80.0% | 0.492 | 0.613 |
| express | 5 | 80.0% | 80.0% | 0.589 | 0.722 |
| fastapi | 5 | 60.0% | 60.0% | 0.551 | 0.545 |
| fastify | 5 | 60.0% | 60.0% | 0.629 | 0.622 |
| flask | 5 | 100.0% | 100.0% | 1.000 | 1.000 |
| gin | 5 | 80.0% | 80.0% | 0.556 | 0.700 |
| laravel | 5 | 80.0% | 100.0% | 0.665 | 0.900 |
| okhttp | 5 | 100.0% | 100.0% | 0.900 | 0.867 |
| rails | 5 | 60.0% | 100.0% | 0.537 | 0.900 |
| riverpod | 5 | 80.0% | 80.0% | 0.817 | 0.817 |
| rust-analyzer | 5 | 100.0% | 100.0% | 0.840 | 0.667 |
| serilog | 5 | 80.0% | 80.0% | 0.492 | 0.568 |
| spring-petclinic | 5 | 60.0% | 80.0% | 0.458 | 0.800 |
| svelte | 5 | 40.0% | 80.0% | 0.266 | 0.614 |
| vapor | 5 | 80.0% | 60.0% | 0.347 | 0.379 |
| vue-core | 5 | 100.0% | 100.0% | 0.617 | 0.700 |
| **Overall** | **85** | **75.3%** | **82.4%** | **0.601** | **0.699** |

Baseline = SigMap's --query (TF-IDF). Rerank = BM25 over camelCase/snake_case-split, stemmed tokens with 3× path-token boost, over the same candidate set.
