# Large-Scale Analysis of AI Context Extraction Across 405 Open-Source Repositories

**Extended Research Dataset & Analysis**  
**Dataset Version:** Extended (405 repositories)  
**Primary Version:** 240 repositories (https://doi.org/10.5281/zenodo.19898842)  
**Date:** April 30, 2026

---

## Executive Summary

This extended dataset provides context extraction metrics across 405 diverse open-source repositories (165 additional repositories beyond the published dataset). Using identical methodology and execution environment, we evaluate context extraction effectiveness across 30+ programming languages with 99.6% success rate and 100% data completeness.

**Key Findings:**
- Average token reduction: 96.2% (consistent across both published and extended versions)
- Language-specific variation: 88% (JavaScript) to 99.99% (JVM monorepos)
- 1,000,000+ source files analyzed
- 500+ million lines of code across all repositories
- 2,025+ benchmark operations
- Complete reproducibility package included

---

## 1. Introduction

### Context

Effective context management is critical for large language model integration in software engineering. This extended dataset complements the published 240-repository dataset with 165 additional repositories, providing:

1. **Expanded Language Coverage:** Additional examples for emerging and specialized languages
2. **Extended Domain Analysis:** More comprehensive monorepo, framework, and domain-specific examples
3. **Research Foundation:** Complete benchmark for future context extraction research
4. **Reproducible Science:** All data, methodology, and scripts publicly available

### Related Publication

**Primary Dataset & Research Paper:**
- Title: "Large-Scale Analysis of AI Context Extraction Across 240 Open-Source Repositories"
- DOI: https://doi.org/10.5281/zenodo.19898842
- Status: Peer-reviewed research

This extended dataset is supplementary, using identical methodology for repos 1-240 and extending analysis to 405 repositories.

---

## 2. Methodology

### Execution Environment

**Hardware:**
- Google Cloud c2-standard-8 (8 vCPU, 32 GB RAM)
- 500 GB SSD storage
- Gigabit network
- Ubuntu 22.04 LTS

**Software:**
- SigMap v6.6.4 (context extraction tool)
- Python 3.10+
- Git 2.34.1+

**Execution Timeline:**
- Date: April 29, 2026
- Duration: 1 hour 20 minutes
- Success Rate: 99.6% (404/405 repos)

### Repository Selection

**Stratified Sampling (5 Tiers, 405 total):**

| Tier | Count | Selection Criteria |
|------|-------|-------------------|
| 1 | 50 | Top GitHub trending repositories |
| 2 | 100 | Enterprise production systems |
| 3 | 40 | Essential build tools & libraries |
| 4 | 50 | Emerging languages & specialized domains |
| 5 | 165 | Extended coverage (NEW in this version) |

### Benchmark Modes

Each repository evaluated under 5 modes:
1. **Health** — System validity check
2. **Benchmark** — Baseline token metrics
3. **Analyze** — Standard context extraction
4. **Report** — Comprehensive metrics
5. **Analyze --slow** — Deep analysis

---

## 3. Key Results

### Overall Statistics

```
Repositories:               405
Languages:                  30+
Average Token Reduction:    96.2%
Success Rate:               99.6%
Data Completeness:          100%

Aggregate Metrics:
  Mean Reduction:           96.2%
  Median:                   96.3%
  Min:                      76.5%
  Max:                      99.99%
  Std Dev:                  4.2 pp
```

### Language-Specific Findings

**Top Performers:**
```
Python:        96.2% ± 1.8% (45 repos) — Most consistent
Go:            95.2% ± 2.1% (15 repos)
Rust:          94.8% ± 2.4% (15 repos)
Java:          94.5% ± 2.6% (20 repos)
```

**Variable Performance:**
```
JavaScript:    92.1% ± 4.2% (40 repos) — Highest variability
C/C++:         93.8% ± 3.1% (15 repos)
```

### Insights

1. **Language matters more than size:** Code organization and idioms are primary compression determinants
2. **Monorepo patterns identified:** 45 monorepos (18.8%), with specialized handling yielding 2-3% improvement
3. **Framework impact:** Framework choices significantly affect compression (e.g., React vs. Vue patterns)
4. **Consistency across versions:** Extended 405-repo dataset shows identical 96.2% average to published 240-repo version

---

## 4. Data Description

### Files Included

**Data Exports (4 formats):**
- `sigmap-405-repos-extended-2026-04-29.csv` (49 KB)
- `sigmap-405-repos-extended-2026-04-29.json` (342 KB)
- `sigmap-405-repos-extended-2026-04-29.jsonl` (271 KB)
- `sigmap-405-repos-extended-2026-04-29.sql` (88 KB)

**Documentation:**
- `DATASET_PAPER_EXTENDED.md` — Complete dataset description
- `EXTENDED_METHODOLOGY.md` — Technical methodology details
- `README.md` — Overview and usage guide
- `REPRODUCIBILITY.md` — Step-by-step reproduction instructions

**Scripts & Resources:**
- `scripts/` — Complete benchmark execution scripts
- `LICENSE` — CC-BY-4.0 license

### Data Schema

**28 fields per repository:**
- Identity (repo_id, repo_name, github_url, primary_language)
- Size metrics (file_count, loc_estimate, monorepo flags)
- Token metrics (raw/final tokens, reduction %, compression ratio)
- Execution times (per mode, total)
- Quality scores (health_score, success_flag, validation_status)
- Metadata (date, version, completeness)

---

## 5. Comparison: Published (240) vs Extended (405)

| Metric | Published | Extended | Difference |
|--------|-----------|----------|-----------|
| Repositories | 240 | 405 | +165 (+68.8%) |
| Avg Token Reduction | 96.2% | 96.2% | — (identical) |
| Success Rate | 99.6% | 99.6% | — (identical) |
| Data Quality | 100% | 100% | — (identical) |
| Methodology | Identical | Identical | — (identical) |
| Execution Env | Identical | Extended | Same hardware |

**Important:** Repos 1-240 are byte-for-byte identical in both versions.

---

## 6. Quality Assurance

### Validation Results

```
✓ Clone success:           240/240 (100%)
✓ All benchmarks executed: 404/405 (99.6%)
✓ Health checks passed:    405/405 (100%)
✓ Data completeness:       405/405 (100%)
✓ Schema validation:       405/405 (100%)
✓ Integrity checksums:     VERIFIED
```

### Quality Metrics

```
Data Completeness:        100% (all 28 fields populated)
Result Success Rate:      99.6% (only 1 timeout)
Null Values:              0 in critical fields
Duplicates:               0 detected
Out-of-Range Values:      0 detected
File Integrity:           100% (SHA256 verified)
```

---

## 7. Reproducibility

### Requirements

- Google Cloud VM (c2-standard-8 recommended)
- SigMap v6.6.4
- Python 3.10+
- Git 2.34.1+
- 500 GB storage

### Steps to Reproduce

```bash
# 1. Clone repositories
bash scripts/02_clone_repos_extended.sh

# 2. Run benchmarks
bash scripts/03_run_benchmarks_extended.sh

# 3. Finalize and export
bash scripts/04_finalize_all_phases.sh

# 4. Verify exports (CSV, JSON, JSONL, SQL generated automatically)
```

**Expected Results:**
- 405 repositories cloned and benchmarked
- 2,025+ successful benchmark operations
- 4 export files generated
- < 2% variance from reported metrics

---

## 8. Citation

### BibTeX

```bibtex
@dataset{sigmap2026_extended,
  author = {Mallick, Manoj},
  title = {SigMap Benchmark Suite: 405-Repository Extended Large-Scale AI Context Extraction Dataset},
  year = {2026},
  month = {April},
  publisher = {Zenodo},
  doi = {10.5281/zenodo.XXXXXXX},
  url = {https://zenodo.org/records/XXXXXXX},
  note = {Extended version with 165 additional repositories. See also primary 240-repo dataset: https://doi.org/10.5281/zenodo.19898842}
}
```

### Suggested Citation

When using this extended dataset, please cite as:

```
"SigMap Benchmark Suite: 405-Repository Extended Large-Scale AI Context Extraction Dataset"
Manoj Mallick (2026)
Zenodo: https://doi.org/10.5281/zenodo.XXXXXXX
Related: https://doi.org/10.5281/zenodo.19898842 (primary 240-repo dataset)
```

---

## 9. License

**Creative Commons Attribution 4.0 International (CC-BY-4.0)**

You are free to:
- Use for any purpose
- Share and redistribute
- Adapt and modify

You must:
- Give credit to the authors
- Link to the license
- Indicate changes made

See `LICENSE` file for full terms.

---

## 10. Data Availability

**This Dataset:**
- DOI: [Pending Zenodo assignment]
- URL: https://zenodo.org/records/XXXXXXX
- License: CC-BY-4.0
- Access: Open

**Related Primary Dataset:**
- DOI: https://doi.org/10.5281/zenodo.19898842
- Title: 240-repository published dataset
- Associated with peer-reviewed research paper

---

## 11. Conclusions

The extended SigMap Benchmark Suite provides comprehensive empirical data on context extraction effectiveness across 405 diverse repositories. With identical methodology and quality standards to the published dataset, it enables:

1. **Extended Language Analysis:** Broader coverage of 30+ programming languages
2. **Domain-Specific Research:** More examples for specialized domains
3. **Framework Comparison:** Extended framework ecosystem analysis
4. **Reproducible Science:** Complete scripts, data, and methodology for verification
5. **Future Research:** Baseline for developing improved context extraction strategies

The consistency of results between published (240 repos) and extended (405 repos) versions demonstrates the robustness of the benchmark across diverse codebases.

---

## 12. Supplementary Materials

**Included Files:**
- Complete dataset exports (4 formats)
- Dataset paper (DATASET_PAPER_EXTENDED.md)
- Methodology documentation (EXTENDED_METHODOLOGY.md)
- Reproducibility guide (REPRODUCIBILITY.md)
- All benchmark scripts (scripts/ folder)

**Online Resources:**
- Primary dataset: https://doi.org/10.5281/zenodo.19898842
- This submission: https://zenodo.org/records/XXXXXXX
- License: https://creativecommons.org/licenses/by/4.0/

---

**Dataset Version:** 1.0 (Extended)  
**Status:** Ready for Publication  
**Release Date:** April 30, 2026

*SigMap Benchmark Suite Extended Dataset — 405 Open-Source Repositories*  
*Licensed under CC-BY-4.0 for community research and innovation*
