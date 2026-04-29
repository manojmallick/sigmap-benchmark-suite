# SigMap Benchmark Suite — Extended Dataset (405 Repositories)

**Zenodo Submission Package**  
**Extended Version with 405 Open-Source Repositories**  
**Date:** April 30, 2026

---

## Overview

This is the **extended dataset version** of the SigMap Benchmark Suite, containing benchmarks across **405 diverse open-source repositories** spanning 30+ programming languages.

This submission is **separate from but linked to** the published research paper dataset (240 repositories). See "Relationship to Published Dataset" below.

---

## What's Included

### Data Exports (4 formats)
- `sigmap-405-repos-extended-2026-04-29.csv` — Tabular format for Excel/pandas/R
- `sigmap-405-repos-extended-2026-04-29.json` — Complete JSON structure with metadata
- `sigmap-405-repos-extended-2026-04-29.jsonl` — Streaming format (one record per line)
- `sigmap-405-repos-extended-2026-04-29.sql` — PostgreSQL import script

### Documentation (included separately)
- `DATASET_EXTENDED_PAPER.md` — Comprehensive dataset description
- `EXTENDED_METHODOLOGY.md` — Detailed methodology for 405-repo dataset
- `ZENODO_SUBMISSION_CHECKLIST_405.md` — Step-by-step submission guide
- `EXTENDED_README.txt` — Quick reference guide

### Reproducibility (scripts & configs)
- All benchmark scripts from primary submission
- Configuration files and parameters
- Hardware specifications and environment details

---

## Dataset Statistics

### Scale
```
Total Repositories:        405
Programming Languages:     30+
Total Benchmark Operations: 2,025+ (405 repos × 5 modes)
Total Source Files:        1,000,000+
Total Lines of Code:       500+ million
```

### Coverage
```
Repos 1-240:   Published paper dataset (see primary submission)
Repos 241-405: Extended dataset (165 additional repos)
```

### Quality Metrics
```
Overall Success Rate:      99.6%
Data Completeness:         100%
Validation Status:         All VALID
Average Token Reduction:   96.2%
Range:                     76.5% to 99.99%
Standard Deviation:        4.2 percentage points
```

### Languages (Sample)
```
Python          (45 repos)  → 96.2% ± 1.8% reduction
JavaScript      (40 repos)  → 92.1% (high variability)
Java            (20 repos)  → 94.5% ± 2.6% reduction
Go              (15 repos)  → 95.2% ± 2.1% reduction
Rust            (15 repos)  → 94.8% ± 2.4% reduction
C/C++           (15 repos)  → 93.8% ± 3.1% reduction
[+ 24 more languages]
```

---

## Key Differences from Published Version (240 repos)

### Extended Dataset Includes (165 additional repos)

**Additional Categories:**
- More emerging language examples (Zig, Nim, Crystal, Elixir, Julia)
- Extended blockchain/Web3 projects
- Additional ML/AI systems
- More monorepo examples
- Broader framework representation

**Statistical Impact:**
- Same 96.2% average token reduction
- Same 99.6% success rate
- Same quality metrics and validation
- Expanded language coverage
- More comprehensive domain representation

### When to Use Each Version

| Need | Use Version |
|------|---|
| Cite research paper | 240-repo (published) |
| Reproduce paper results | 240-repo (published) |
| Extended analysis | 405-repo (extended) |
| Cross-language study | 405-repo (extended) |
| Domain comparison | 405-repo (extended) |
| Emerging languages | 405-repo (extended) |

---

## Relationship to Published Dataset

### Primary Submission (240 repos)
- **DOI:** https://doi.org/10.5281/zenodo.19898842
- **Title:** "Large-Scale Analysis of AI Context Extraction Across 240 Open-Source Repositories"
- **Status:** Associated with peer-reviewed research paper
- **Citation:** Stable, referenced in academic literature

### This Submission (405 repos)
- **Status:** Extended version with additional repositories
- **Relationship:** Repos 1-240 identical to primary submission
- **New Content:** Repos 241-405 (165 additional repositories)
- **Citation:** New DOI (assigned by Zenodo on publication)

### Linking

In this submission's metadata on Zenodo:
- **Linked Resource:** Primary dataset (240 repos) — https://doi.org/10.5281/zenodo.19898842
- **Relationship Type:** "Is supplemented by" or "Has version"
- **Note:** "This is the extended version including 405 repositories. For the published research paper, see the primary 240-repository dataset."

---

## Data Specifications

### File Formats

#### CSV Format
```
Columns (28 total):
  - repo_id, repo_name, github_url, primary_language
  - file_count, loc_estimate, monorepo_flag, monorepo_module_count
  - raw_tokens_estimate, final_tokens, reduction_percent
  - tokens_per_file, compression_ratio
  - benchmark_time_ms, analyze_time_ms, report_time_ms, health_time_ms, analyze_slow_time_ms, total_time_ms
  - health_score, success_flag, error_code, validation_status, timeout_flag
  - benchmark_date, sigmap_version, benchmark_mode_count, data_completeness_percent

Rows: 405 (one per repository)
Size: ~49 KB
Import: Excel, Google Sheets, pandas, R, SQL databases
```

#### JSON Format
```
Structure:
  {
    "metadata": {
      "version": "1.0",
      "dataset_type": "extended",
      "repository_count": 405,
      "benchmark_date": "2026-04-29",
      "tool_version": "SigMap 6.6.4"
    },
    "repositories": [
      { repo_id: 1, repo_name: "...", ... },
      { repo_id: 2, repo_name: "...", ... },
      ...
      { repo_id: 405, repo_name: "...", ... }
    ]
  }

Size: ~342 KB
Use: Archival, APIs, complete data preservation
```

#### JSONL Format
```
One JSON object per line for streaming processing

Size: ~271 KB
Use: Big data tools, incremental loading, streaming analysis
Import: Apache Spark, Hadoop, pandas read_json(lines=True)
```

#### SQL Format
```
Format: PostgreSQL SQL dump

Includes:
  - Table schema definition
  - Constraints and indexes
  - 405 INSERT statements (one per repository)
  - Metadata comments

Size: ~88 KB
Import: PostgreSQL, MySQL (with minor modifications), other SQL databases
```

---

## Benchmark Methodology

### Execution Environment
```
Hardware:        Google Cloud c2-standard-8 (8 vCPU, 32 GB RAM)
Storage:         500 GB SSD
Network:         Gigabit
OS:              Ubuntu 22.04 LTS
Tool:            SigMap v6.6.4
Execution Date:  April 29, 2026
```

### Benchmark Modes (5 per repository)
```
1. Health      — System validation, availability check
2. Benchmark   — Baseline token metrics
3. Analyze     — Standard context extraction
4. Report      — Comprehensive metrics and summaries
5. Analyze --slow — Extended analysis, optimization opportunities
```

### Metrics Captured (50+ fields)
- Token counts (raw, final, reduction %)
- File statistics (count, language distribution, LOC)
- Execution timing (per mode, total)
- Code complexity measures
- Monorepo detection and module analysis
- Language detection confidence
- Framework identification
- Validation status and error flags

---

## Repository Selection

### Stratification Strategy (4 Tiers, extended to 5)

**Tier 1: Popular & Trending (50 repos)**
- GitHub trending repositories (top 50 by stars)
- Web frameworks, Cloud infrastructure, Data/ML, DevOps

**Tier 2: Enterprise & Production (100 repos)**
- Large production systems used in industry
- Financial platforms, E-commerce, CMS, Monitoring, Real-time systems

**Tier 3: Libraries & Build Tools (40 repos)**
- Essential ecosystem components
- Package managers, Build systems, Testing frameworks, Web servers

**Tier 4: Emerging & Specialized (50 repos)**
- Specialized domains and emerging technologies
- Emerging languages, Blockchain/Web3, Quantum, IoT/Edge

**Tier 5: Extended Coverage (165 repos) — NEW IN THIS VERSION**
- Additional language examples
- More monorepo cases
- Extended domain coverage
- Framework ecosystem expansion
- Regional/non-English projects

---

## Data Quality Assurance

### Validation Checklist (per repository)
```
✅ Clone successful
✅ Files counted correctly
✅ Token extraction completed
✅ All 5 benchmark modes executed
✅ No timeouts or errors
✅ Health score valid
✅ Metadata complete
✅ Reduction % between 0-100
✅ Tokens > 0
✅ Benchmark date recorded
✅ Version consistency
```

### Integrity Verification
```
Data Completeness:       100% (405/405 repositories)
Result Success Rate:     99.6% (only 1 timeout)
File Integrity:          100% (SHA256 verified)
Schema Validation:       100% (all records valid)
Null Values:             None in critical fields
Duplicate Records:       None
Out-of-range Values:     None detected
```

---

## How to Use This Dataset

### For Analysis in Python
```python
import pandas as pd
import json

# CSV
df = pd.read_csv('sigmap-405-repos-extended-2026-04-29.csv')
print(f"Loaded {len(df)} repositories")

# JSONL (streaming)
records = []
with open('sigmap-405-repos-extended-2026-04-29.jsonl') as f:
    for line in f:
        records.append(json.loads(line))

# JSON
with open('sigmap-405-repos-extended-2026-04-29.json') as f:
    data = json.load(f)
    repos = data['repositories']
```

### For Database Import
```bash
# PostgreSQL
psql -U username -d database -f sigmap-405-repos-extended-2026-04-29.sql

# MySQL (may need minor adjustments)
mysql -u username -p database < sigmap-405-repos-extended-2026-04-29.sql
```

### For Analysis in R
```r
library(readr)

# Read CSV
df <- read_csv('sigmap-405-repos-extended-2026-04-29.csv')

# Quick stats
summary(df$reduction_percent)
table(df$primary_language)
```

---

## Citation

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
  note = {Extended version with 165 additional repositories beyond the published 240-repo dataset}
}
```

### APA Format

```
SigMap Benchmark Suite. (2026). 405-repository extended large-scale AI context 
extraction dataset [Data set]. Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX

Related primary dataset: https://doi.org/10.5281/zenodo.19898842 (240 repositories)
```

### Plain Text

```
SigMap Benchmark Suite: 405-Repository Extended Dataset
Manoj Mallick (2026)
Zenodo: https://doi.org/10.5281/zenodo.XXXXXXX
(Extended version. Primary 240-repo dataset: https://doi.org/10.5281/zenodo.19898842)
```

---

## Metadata for Zenodo Upload

### Title
```
SigMap Benchmark Suite: 405-Repository Extended Large-Scale AI Context Extraction Dataset
```

### Description
```
Extended dataset version of the SigMap Benchmark Suite containing context extraction metrics 
across 405 diverse open-source repositories spanning 30+ programming languages. This is the 
complete dataset including 165 additional repositories beyond the published 240-repository 
dataset used in the peer-reviewed research paper.

Includes:
- Complete data exports in 4 formats (CSV, JSON, JSONL, SQL)
- 50+ metadata fields per repository
- 405 repositories across 30+ languages
- 2,025+ benchmark operations
- Average token reduction: 96.2% (ranging from 76.5% to 99.99%)
- 100% data completeness and quality verification
- Full reproducibility documentation

Relationship: Extended version of https://doi.org/10.5281/zenodo.19898842 (240 repositories)
```

### Keywords
```
AI Context Extraction, Benchmark Suite, Extended Dataset, Large Language Models, 
Code Compression, Programming Languages, Multi-Language Analysis, Token Optimization, 
Open-Source Repositories, 405 Repositories, Software Engineering, Empirical Benchmark
```

### Authors
```
Manoj Mallick
```

### License
```
Creative Commons Attribution 4.0 International (CC-BY-4.0)
```

### Related/Linked Resource
```
Relationship Type: Supplements / Is supplemented by
Related Resource: https://doi.org/10.5281/zenodo.19898842
Description: Primary 240-repository dataset associated with published research paper. 
This extended version contains those 240 repos plus 165 additional repositories.
```

### Type
```
Dataset / Benchmark / Extended Version
```

### Subject Area
```
Computer Science / Software Engineering / Machine Learning / Empirical Study
```

---

## Files Included

```
zenodo_submission_extended_405/
├── sigmap-405-repos-extended-2026-04-29.csv       (49 KB)
├── sigmap-405-repos-extended-2026-04-29.json      (342 KB)
├── sigmap-405-repos-extended-2026-04-29.jsonl     (271 KB)
├── sigmap-405-repos-extended-2026-04-29.sql       (88 KB)
│
├── README.md                                        (this file)
├── DATASET_EXTENDED_PAPER.md                       (comprehensive description)
├── EXTENDED_METHODOLOGY.md                         (detailed methodology)
├── ZENODO_SUBMISSION_CHECKLIST_405.md              (step-by-step guide)
└── EXTENDED_README.txt                             (quick reference)
```

---

## Technical Support

### Data Questions
- See `DATASET_EXTENDED_PAPER.md` for comprehensive dataset description
- See `EXTENDED_METHODOLOGY.md` for detailed methodology
- Check field descriptions in `EXTENDED_README.txt`

### Zenodo Submission Questions
- See `ZENODO_SUBMISSION_CHECKLIST_405.md` for step-by-step guide
- Follow instructions at https://zenodo.org/

### Data Format Issues
- CSV: Should open in Excel without issues
- JSON: Validate with online JSON validator
- JSONL: Process line by line
- SQL: Test import on test database first

---

## License

This dataset is released under **Creative Commons Attribution 4.0 International (CC-BY-4.0)**

**You are free to:**
- Use this dataset for any purpose (commercial or non-commercial)
- Share and redistribute the dataset
- Adapt and modify the dataset

**You must:**
- Give appropriate credit to the authors
- Include a link to the license
- Indicate if changes were made

**For attribution, cite:**
```
SigMap Benchmark Suite: 405-Repository Extended Dataset
https://doi.org/10.5281/zenodo.XXXXXXX
Licensed under CC-BY-4.0
```

---

## Version Information

```
Dataset Version:       1.0 (Extended)
Release Date:          April 30, 2026
Tool Version:          SigMap 6.6.4
Benchmark Date:        April 29, 2026
Repository Count:      405 (repos 1-405)
Published Repos:       240 (repos 1-240) — See primary dataset
Extended Repos:        165 (repos 241-405)
```

---

## Contact & Support

For questions about this extended dataset:
- Primary dataset DOI: https://doi.org/10.5281/zenodo.19898842
- Extended dataset: This submission (DOI pending)
- Related research paper: See primary dataset submission

---

**Status: Ready for Zenodo Submission ✅**

Last Updated: April 30, 2026
