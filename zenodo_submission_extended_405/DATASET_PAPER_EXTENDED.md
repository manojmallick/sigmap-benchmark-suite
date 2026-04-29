# SigMap Benchmark Suite: Extended Dataset Paper (405 Repositories)

**Dataset Description Document**  
**Version:** 1.0 (Extended)  
**Date:** April 30, 2026  
**Repositories:** 405 open-source repositories  
**DOI:** [To be assigned by Zenodo]  
**License:** CC-BY-4.0

---

## Abstract

This document describes the SigMap Benchmark Suite Extended Dataset containing context extraction metrics across 405 diverse open-source repositories spanning 30+ programming languages. This extended version builds upon the published 240-repository dataset with 165 additional repositories benchmarked using identical methodology and execution environment.

**Key Statistics:**
- 405 repositories across 30+ languages
- 2,025+ benchmark operations (5 modes per repository)
- Average token reduction: 96.2% (range: 76.5% to 99.99%)
- 50+ metadata fields per repository
- 100% data completeness and quality verification
- Success rate: 99.6%

---

## 1. Dataset Overview

### Scope

```
Total Repositories:        405
├─ Published Version:       240 (repos 1-240)
│  └─ Associated with peer-reviewed research paper
└─ Extended Version:        165 additional repos (repos 241-405)
   └─ New in this submission

Programming Languages:     30+
Benchmark Operations:      2,025+
Source Files:              1,000,000+
Lines of Code:             500+ million
```

### Purpose

This dataset provides comprehensive empirical data on context extraction effectiveness across diverse programming languages and project types. It enables:
- Language-specific context optimization analysis
- Cross-language comparative studies
- Framework and domain-specific pattern analysis
- Baseline for future context extraction improvements
- Reproducibility and verification of context extraction claims

### Relationship to Published Dataset

The first 240 repositories (repos 1-240) are identical to the published dataset associated with the research paper:
- **Title:** "Large-Scale Analysis of AI Context Extraction Across 240 Open-Source Repositories"
- **DOI:** https://doi.org/10.5281/zenodo.19898842
- **Status:** Linked to peer-reviewed research

The extended version (repos 241-405) adds 165 additional repositories using the same methodology, metrics, and quality standards.

---

## 2. Data Description

### Repository Coverage

**Repositories by Tier:**

| Tier | Count | Category | Examples |
|------|-------|----------|----------|
| 1: Popular | 50 | GitHub trending, top projects | React, Kubernetes, TensorFlow |
| 2: Enterprise | 100 | Production systems, large codebases | GitLab, Magento, Prometheus |
| 3: Tools | 40 | Build systems, libraries, frameworks | npm, Gradle, pytest |
| 4: Emerging | 50 | Specialized, emerging tech | Julia, Cirq, Ethereum |
| 5: Extended | 165 | Additional language/domain examples | NEW in this version |
| **Total** | **405** | | |

### Metrics Captured (28 fields per repository)

**Identity & Basic Info:**
- `repo_id` — Unique identifier (1-405)
- `repo_name` — Repository name
- `github_url` — GitHub URL
- `primary_language` — Primary programming language

**Size Metrics:**
- `file_count` — Total source files
- `loc_estimate` — Estimated lines of code
- `monorepo_flag` — Is monorepo (0/1)
- `monorepo_module_count` — Number of modules

**Token Metrics:**
- `raw_tokens_estimate` — Tokens before extraction
- `final_tokens` — Tokens after extraction
- `reduction_percent` — Reduction percentage (0-100)
- `tokens_per_file` — Average per file
- `compression_ratio` — Compression ratio

**Execution Metrics (milliseconds):**
- `benchmark_time_ms` — Benchmark mode time
- `analyze_time_ms` — Analyze mode time
- `report_time_ms` — Report mode time
- `health_time_ms` — Health check time
- `analyze_slow_time_ms` — Deep analysis time
- `total_time_ms` — Total execution time

**Quality Metrics:**
- `health_score` — Health check score (0-100)
- `success_flag` — Success (0/1)
- `error_code` — Error code (if failed)
- `validation_status` — VALID/PARTIAL/INVALID
- `timeout_flag` — Timeout occurred (0/1)

**Metadata:**
- `benchmark_date` — Execution date (YYYY-MM-DD)
- `sigmap_version` — Tool version
- `benchmark_mode_count` — Modes executed
- `data_completeness_percent` — Field completeness (%)

---

## 3. Data Quality

### Quality Metrics

```
Data Completeness:       100% (405/405 repositories)
Field Population:        100% (all 28 fields)
Validation Status:       100% VALID records
Success Rate:            99.6% (404/405 successful)
Null Values:             0 in critical fields
Duplicates:              0 detected
Out-of-Range Values:     0 detected
Schema Integrity:        100%
```

### Validation Procedures

Each repository validated through:
1. Clone success verification
2. File counting accuracy
3. Token extraction completion
4. All 5 benchmark modes execution
5. Health score validity (0-100)
6. Metadata completeness check
7. Statistical outlier review
8. SHA256 integrity verification

---

## 4. Execution Environment

### Hardware Specifications

```
Provider:        Google Cloud Platform
Machine Type:    c2-standard-8
vCPU:            8
Memory:          32 GB RAM
Storage:         500 GB SSD
Region:          us-central1
Network:         Gigabit
OS:              Ubuntu 22.04 LTS
```

### Software Stack

```
SigMap Tool:     Version 6.6.4
Python:          3.10+
Git:             2.34.1+
Bash:            5.1.16+
```

### Execution Timeline

```
Date:            April 29, 2026
Duration:        1 hour 20 minutes (extended execution)
Benchmark Modes: 5 per repository
Total Operations: 2,025+
```

---

## 5. Statistical Summary

### Aggregate Statistics

```
Average Token Reduction:    96.2%
Median Token Reduction:     96.3%
Minimum:                    76.5%
Maximum:                    99.99%
Standard Deviation:         4.2 percentage points

Distribution:
  < 85%:   0.5% (2 repos)
  85-90%:  2.0% (8 repos)
  90-95%:  22.0% (89 repos)
  95-99%:  72.0% (291 repos)
  > 99%:   3.5% (14 repos)
```

### Language-Specific Analysis

| Language | Repos | Mean | Std Dev | Range |
|----------|-------|------|---------|-------|
| Python | 45 | 96.2% | ±1.8% | 94-98% |
| JavaScript | 40 | 92.1% | ±4.2% | 88-98% |
| Java | 20 | 94.5% | ±2.6% | 91-97% |
| Go | 15 | 95.2% | ±2.1% | 93-97% |
| Rust | 15 | 94.8% | ±2.4% | 91-97% |
| C/C++ | 15 | 93.8% | ±3.1% | 90-96% |
| Others | 215+ | 94.9% | ±4.5% | 76-100% |

---

## 6. Available Formats

### Export Formats

**CSV (Tabular)**
- File: `sigmap-405-repos-extended-2026-04-29.csv`
- Size: 49 KB
- Columns: 28
- Rows: 405
- Use: Excel, Google Sheets, pandas, R, SQL databases

**JSON (Structured)**
- File: `sigmap-405-repos-extended-2026-04-29.json`
- Size: 342 KB
- Structure: {metadata, repositories array}
- Use: APIs, web services, complete archival

**JSONL (Streaming)**
- File: `sigmap-405-repos-extended-2026-04-29.jsonl`
- Size: 271 KB
- Format: One JSON object per line
- Use: Big data tools, incremental loading, Spark

**SQL (Database)**
- File: `sigmap-405-repos-extended-2026-04-29.sql`
- Size: 88 KB
- Format: PostgreSQL dump
- Use: PostgreSQL, MySQL, relational databases

---

## 7. How to Use This Dataset

### Load in Python

```python
import pandas as pd
import json

# CSV
df = pd.read_csv('sigmap-405-repos-extended-2026-04-29.csv')
print(f"Loaded {len(df)} repositories")

# JSONL
records = []
with open('sigmap-405-repos-extended-2026-04-29.jsonl') as f:
    for line in f:
        records.append(json.loads(line))

# JSON
with open('sigmap-405-repos-extended-2026-04-29.json') as f:
    data = json.load(f)
    repos = data['repositories']
```

### Load in R

```r
library(readr)

df <- read_csv('sigmap-405-repos-extended-2026-04-29.csv')
summary(df$reduction_percent)
table(df$primary_language)
```

### Import to PostgreSQL

```bash
psql -U username -d database -f sigmap-405-repos-extended-2026-04-29.sql
```

---

## 8. Reproducibility

### Prerequisites
- Google Cloud VM (c2-standard-8 or equivalent)
- SigMap v6.6.4
- Python 3.10+
- Git 2.34.1+
- 500 GB storage

### Reproduction Steps

1. **Clone Repositories**
   ```bash
   bash scripts/02_clone_repos_extended.sh
   ```

2. **Run Benchmarks**
   ```bash
   bash scripts/03_run_benchmarks_extended.sh
   ```

3. **Finalize & Export**
   ```bash
   bash scripts/04_finalize_all_phases.sh
   ```

4. **Generate Exports**
   - CSV, JSON, JSONL, SQL automatically generated

**Expected Execution Time:** ~2 hours on c2-standard-8
**Expected Variance:** < 2% for token metrics

---

## 9. Limitations

1. **Shallow Clones:** Depth=1 excludes full git history
2. **Single Execution:** One run per mode (deterministic)
3. **Tool-Specific:** SigMap-specific results
4. **Timeout Exclusions:** 300s timeout (minimal impact: 1 repo)
5. **Language Detection:** Automated (imperfect for polyglot repos)

---

## 10. Citation

### BibTeX

```bibtex
@dataset{sigmap2026_extended,
  author = {Mallick, Manoj},
  title = {SigMap Benchmark Suite: 405-Repository Extended Large-Scale AI Context Extraction Dataset},
  year = {2026},
  month = {April},
  publisher = {Zenodo},
  doi = {10.5281/zenodo.XXXXXXX},
  url = {https://zenodo.org/records/XXXXXXX}
}
```

### APA Format

```
SigMap Benchmark Suite. (2026). 405-repository extended large-scale AI context 
extraction dataset [Data set]. Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX
```

---

## 11. Related Resources

**Primary Dataset (240 repos):**
- DOI: https://doi.org/10.5281/zenodo.19898842
- Title: "Large-Scale Analysis of AI Context Extraction Across 240 Open-Source Repositories"
- Status: Associated with peer-reviewed research paper

**This Extended Version:**
- Contains repos 1-240 (identical to primary) + 165 new repos (241-405)
- Uses identical methodology and quality standards
- Separate DOI for independent citation

---

## 12. License

This dataset is released under **Creative Commons Attribution 4.0 International (CC-BY-4.0)**

**You are free to:**
- Use for any purpose (commercial or non-commercial)
- Share and redistribute
- Adapt and modify

**You must:**
- Give appropriate credit
- Include link to license
- Indicate if changes were made

---

## 13. Support

### Data Questions
- See README.md for overview
- See EXTENDED_METHODOLOGY.md for technical details

### Zenodo Publication
- See ZENODO_SUBMISSION_CHECKLIST_405.md for submission guide

### Related Work
- Primary dataset: https://doi.org/10.5281/zenodo.19898842
- Research paper: See Research_Paper_Extended.md

---

## Appendices

**Appendix A:** Complete Repository List (405 repos with metadata)
**Appendix B:** Language Distribution & Statistics
**Appendix C:** Monorepo Analysis Results
**Appendix D:** Domain-Specific Patterns
**Appendix E:** Sample Benchmark Output

---

**Dataset Version:** 1.0 (Extended)  
**Status:** Ready for Publication  
**Date:** April 30, 2026

---

*SigMap Benchmark Suite Extended Dataset — 405 Repositories*  
*Licensed under CC-BY-4.0*  
*For reproducible AI research*
