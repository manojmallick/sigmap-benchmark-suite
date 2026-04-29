# SigMap Benchmark Suite — Reproducibility Guide

## How to Reproduce This Benchmark

This dataset includes complete scripts, configurations, and parameters to reproduce the full 240-repository benchmark analysis.

---

## Prerequisites

```bash
# Required
- Ubuntu 22.04 LTS (or compatible Linux)
- Git v2.34.1+
- Python 3.8+
- Bash 4.0+
- ~100 GB disk space (for 240 repos)

# Optional
- GNU parallel (for faster execution)
- jq (for JSON processing)
```

---

## Step 1: Download This Dataset

```bash
# Extract the zenodo dataset to your working directory
unzip sigmap-benchmark-suite.zip
cd sigmap-benchmark-suite
```

---

## Step 2: Review Repository List

The dataset includes 240 repositories across 4 tiers:

```bash
# View tier information
cat scripts/02_clone_repos_extended_500.sh | grep -A 50 "PHASE_1A_REPOS"
```

**Expected:**
- Tier 1: 50 repos (popular & trending)
- Tier 2: 100 repos (enterprise systems)
- Tier 3: 40 repos (libraries & tools)
- Tier 4: 50 repos (emerging & specialized)

---

## Step 3: Clone Repositories

```bash
# Create repos directory
mkdir -p repos

# Run clone script (8 parallel workers)
bash scripts/02_clone_repos_extended_500.sh

# Expected output
# - ~31 GB disk usage
# - 240 repos cloned in ~8 minutes
# - 92% success rate (240/260 attempted)
```

**Note:** This will clone ALL 240 repositories. You can modify the script to clone specific tiers or repos.

---

## Step 4: Run Benchmarks

```bash
# Run benchmark suite (5 modes per repo)
bash scripts/03_run_benchmarks_extended.sh

# Expected output
# - 1,775 operations total
# - ~87 minutes execution
# - 99.6% success rate
# - 2,835+ JSON result files
```

**Output:** `results/raw/` directory with JSON files per repo

---

## Step 5: Aggregate Results

```bash
# Aggregate and export
bash scripts/04_finalize_all_phases.sh

# Expected output
# - sigmap-240-repos.csv (CSV export)
# - sigmap-240-repos.json (JSON export)
# - sigmap-240-repos.jsonl (JSONL export)
# - sigmap-240-repos.sql (SQL export)
```

---

## Step 6: Verify Results

```bash
# Check result files
ls -lah results/exports/

# Expected file sizes
# CSV: ~50 KB
# JSON: ~343 KB
# JSONL: ~272 KB
# SQL: ~88 KB

# Validate completeness
python3 infrastructure/export_academic_datasets.py --validate results/exports/

# Expected: 240 repositories, 100% metadata completeness
```

---

## Advanced: Custom Repository List

To run the benchmark on a different set of repositories:

```bash
# Edit scripts/02_clone_repos_extended_500.sh
# Modify the PHASE_1A_REPOS, PHASE_1B_REPOS, PHASE_2_REPOS arrays
# Format: "https://github.com/owner/repo label"

# Example:
CUSTOM_REPOS=(
  "https://github.com/facebook/react react"
  "https://github.com/torvalds/linux linux"
  "https://github.com/kubernetes/kubernetes kubernetes"
)

# Then run as normal
bash scripts/02_clone_repos_extended_500.sh
```

---

## Environment Variables

```bash
# Set parallel workers (default: 8)
export PARALLEL_WORKERS=4

# Set benchmark timeout (default: 300 seconds)
export BENCHMARK_TIMEOUT=600

# Set log level (default: INFO)
export LOG_LEVEL=DEBUG

# Then run scripts
bash scripts/03_run_benchmarks_extended.sh
```

---

## Troubleshooting

### Clone Failures
```bash
# If repos fail to clone, check:
# 1. Network connectivity
# 2. Repository URL validity
# 3. GitHub rate limits (wait 1 hour)

# Retry failed clones
bash scripts/02_clone_repos_extended_500.sh --retry
```

### Benchmark Timeouts
```bash
# If benchmarks timeout, increase timeout:
export BENCHMARK_TIMEOUT=600
bash scripts/03_run_benchmarks_extended.sh

# Or run single repo for debugging:
bash scripts/03_run_benchmarks_extended.sh --repo facebook/react
```

### Export Issues
```bash
# Regenerate exports from existing results:
python3 infrastructure/export_academic_datasets.py \
  --input results/raw/ \
  --output results/exports/ \
  --format csv,json,jsonl,sql
```

---

## Expected Output

### Directory Structure
```
sigmap-benchmark-suite/
├── repos/                       (240 cloned repositories)
├── results/
│   ├── raw/                    (2,835+ JSON result files)
│   └── exports/                (CSV, JSON, JSONL, SQL)
├── scripts/                    (All execution scripts)
└── [this guide]
```

### Statistics
```
Repositories:              240
Languages:                 30+
Operations:               1,775
Success Rate:             99.6%
Total Tokens Processed:   500M+ LOC
Average Reduction:        96.2%
Data Quality:             100%
```

---

## Validation Checklist

```bash
# Verify clone phase
[ -d "repos" ] && echo "✓ repos directory exists"
[ $(find repos -maxdepth 1 -type d | wc -l) -gt 240 ] && echo "✓ 240+ repos cloned"

# Verify benchmark phase
[ -d "results/raw" ] && echo "✓ results/raw exists"
[ $(find results/raw -name "*.json" | wc -l) -gt 2800 ] && echo "✓ 2,800+ JSON files"

# Verify export phase
[ -f "results/exports/sigmap-240-repos.csv" ] && echo "✓ CSV export complete"
[ -f "results/exports/sigmap-240-repos.json" ] && echo "✓ JSON export complete"
[ -f "results/exports/sigmap-240-repos.jsonl" ] && echo "✓ JSONL export complete"
[ -f "results/exports/sigmap-240-repos.sql" ] && echo "✓ SQL export complete"
```

---

## Performance Expectations

| Phase | Duration | Parallel | Output |
|-------|----------|----------|--------|
| Clone | ~8 min | 8 workers | 240 repos (31 GB) |
| Benchmark | ~87 min | 4 jobs | 1,775 operations |
| Aggregate | ~5 min | - | 4 export formats |
| **Total** | **~100 min** | - | Complete dataset |

---

## Citing This Work

If you use this benchmark in your research, please cite:

```bibtex
@dataset{sigmap2026,
  author = {Manoj Mallick},
  title = {SigMap Benchmark Suite: 240-Repository Large-Scale AI Context Extraction Dataset},
  year = {2026},
  publisher = {Zenodo},
  doi = {10.5281/zenodo.XXXXXXX},
  url = {https://zenodo.org/records/XXXXXXX}
}
```

---

## Support & Questions

For issues or questions about reproducing this benchmark:
- Review METHODOLOGY.md for detailed methods
- Check DATASET_PAPER.md for dataset description
- Review RESEARCH_PAPER.md for analysis details
- Examine scripts/ folder for implementation details

---

## License

This benchmark suite is released under CC-BY-4.0.  
See LICENSE file for details.

---

**Last Updated:** April 29, 2026  
**Status:** Complete and validated  
**Reproducibility:** Full ✓
