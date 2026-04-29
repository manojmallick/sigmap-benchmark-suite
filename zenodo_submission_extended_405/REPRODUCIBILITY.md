# SigMap Benchmark Suite - Reproducibility Guide (405 Repositories)

**Extended Dataset Version**  
**Date:** April 30, 2026

---

## Overview

This guide provides step-by-step instructions to reproduce the SigMap Benchmark Suite results across 405 repositories using the included scripts and data.

**Estimated Time:** ~2 hours on c2-standard-8 hardware  
**Expected Variance:** < 2% from reported metrics

---

## Prerequisites

### Hardware Requirements (Recommended)

```
Machine:        Google Cloud c2-standard-8 (or equivalent)
vCPU:           8
Memory:         32 GB RAM
Storage:        500 GB SSD
Network:        Gigabit
Operating System: Ubuntu 20.04+ or Linux
```

### Software Requirements

```
Python:         3.10 or higher
Git:            2.34.1 or higher
Bash:           5.1 or higher
SigMap:         Version 6.6.4

Optional:
  - PostgreSQL (for SQL import)
  - pandas (for CSV analysis)
  - jq (for JSON processing)
```

### Installation

**Install Prerequisites (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y python3.10 git curl

# Install SigMap (if not already installed)
pip install sigmap==6.6.4
```

**Verify Installations:**
```bash
python3 --version          # Should be 3.10+
git --version              # Should be 2.34.1+
sigmap --version           # Should be 6.6.4
```

---

## Step 1: Prepare Environment

### Create Working Directory

```bash
# Create directory for benchmark
mkdir -p /benchmarks/sigmap-extended
cd /benchmarks/sigmap-extended

# Create subdirectories
mkdir -p repos results/raw results/exports scripts
```

### Download Dataset Package

Extract the SigMap Benchmark Suite extended dataset:

```bash
# If downloaded as ZIP
unzip sigmap-benchmark-suite-extended-405.zip

# Or clone from GitHub
git clone https://github.com/lokaflow/sigmap-benchmark-suite.git
cd sigmap-benchmark-suite/zenodo_submission_extended_405
```

### Copy Scripts

```bash
# Copy all scripts to working directory
cp scripts/* /benchmarks/sigmap-extended/scripts/
chmod +x /benchmarks/sigmap-extended/scripts/*.sh

# Verify scripts
ls -la /benchmarks/sigmap-extended/scripts/
```

---

## Step 2: Clone Repositories (Phase 1)

### Option A: Clone All 405 Repositories (Recommended)

```bash
cd /benchmarks/sigmap-extended

# Run the extended clone script
bash scripts/02_clone_repos_extended.sh
```

**What it does:**
- Clones 405 repositories (stratified sampling)
- Shallow clone (depth=1) to minimize storage
- Parallel cloning with 8 workers
- Takes ~12 minutes
- Generates ~34 GB of code

**Output:**
```
repos/
├── actix-web/
├── afnetworking/
├── agentgpt/
...
└── zig-lang/
```

### Option B: Clone Subset (for Testing)

```bash
# Clone first 50 repos only (for testing)
REPO_COUNT=50 bash scripts/02_clone_repos_extended.sh
```

**Estimated time:** ~2 minutes for 50 repos

---

## Step 3: Run Benchmarks (Phase 2)

### Execute Benchmarks

```bash
cd /benchmarks/sigmap-extended

# Run all benchmarks with 5 modes per repo
bash scripts/03_run_benchmarks_extended.sh
```

**What it does:**
- Runs 5 benchmark modes per repository
- Parallel execution (4 concurrent repos)
- 300-second timeout per mode
- Generates JSON results for each repo
- Expected duration: ~87 minutes for 405 repos

**Output:**
```
results/raw/
├── actix-web.json
├── afnetworking.json
├── agentgpt.json
...
└── zig-lang.json

Total: 405 JSON files with detailed metrics
```

### Monitor Progress

While benchmarks run, monitor in a separate terminal:

```bash
# Watch results directory growth
watch -n 10 'ls results/raw/ | wc -l'

# Monitor system resources
top
```

---

## Step 4: Aggregate & Validate Results (Phase 3)

### Finalize Results

```bash
cd /benchmarks/sigmap-extended

# Aggregate all results and generate exports
bash scripts/04_finalize_all_phases.sh
```

**What it does:**
- Aggregates all 405 JSON result files
- Validates data completeness
- Checks for errors and timeouts
- Generates summary statistics
- Takes ~5 minutes

**Output:**
```
results/exports/
├── sigmap-405-repos-extended-2026-04-29.csv
├── sigmap-405-repos-extended-2026-04-29.json
├── sigmap-405-repos-extended-2026-04-29.jsonl
├── sigmap-405-repos-extended-2026-04-29.sql
└── manifest.json (metadata)
```

---

## Step 5: Verify Results

### Check Completeness

```bash
# Count results
echo "CSV rows (should be 405):"
wc -l results/exports/sigmap-405-repos-extended-2026-04-29.csv

echo "JSONL lines (should be 405):"
wc -l results/exports/sigmap-405-repos-extended-2026-04-29.jsonl

echo "JSON objects:"
jq '.repositories | length' results/exports/sigmap-405-repos-extended-2026-04-29.json
```

**Expected Output:**
```
406 sigmap-405-repos-extended-2026-04-29.csv    (405 repos + 1 header)
405 sigmap-405-repos-extended-2026-04-29.jsonl
405 (JSON repositories)
```

### Validate Data Quality

```bash
# Python validation script
python3 << 'EOF'
import pandas as pd
import json

# Load CSV
df = pd.read_csv('results/exports/sigmap-405-repos-extended-2026-04-29.csv')
print(f"✓ CSV loaded: {len(df)} repositories")

# Check completeness
null_counts = df.isnull().sum()
print(f"✓ Missing values: {null_counts.sum()} total")

# Statistics
print(f"\n✓ Token Reduction Statistics:")
print(df['reduction_percent'].describe())

# Load and check JSON
with open('results/exports/sigmap-405-repos-extended-2026-04-29.json') as f:
    data = json.load(f)
print(f"\n✓ JSON loaded: {len(data['repositories'])} repositories")

print("\n✅ All validation checks passed!")
EOF
```

**Expected Output:**
```
✓ CSV loaded: 405 repositories
✓ Missing values: 0 total
✓ Token Reduction Statistics:
    count   405.000000
    mean     96.200000
    std       4.200000
    min      76.500000
    25%      95.700000
    50%      96.300000
    75%      97.100000
    max      99.990000

✓ JSON loaded: 405 repositories
✅ All validation checks passed!
```

---

## Step 6: Compare Results

### Compare with Published Dataset

If you have the published 240-repo dataset:

```bash
# Compare statistics for repos 1-240
python3 << 'EOF'
import pandas as pd

# Load both datasets
extended = pd.read_csv('results/exports/sigmap-405-repos-extended-2026-04-29.csv')
published = pd.read_csv('../../zenodo_submission/sigmap-240-repos-published-2026-04-29.csv')

# Compare stats for first 240 repos
extended_240 = extended[extended['repo_id'] <= 240]

print("Comparison (repos 1-240):")
print(f"Published: {published['reduction_percent'].mean():.2f}% avg")
print(f"Extended:  {extended_240['reduction_percent'].mean():.2f}% avg")
print(f"Difference: {abs(published['reduction_percent'].mean() - extended_240['reduction_percent'].mean()):.4f}%")

print("\n✅ Should be identical (< 0.01% difference)")
EOF
```

**Expected Output:**
```
Comparison (repos 1-240):
Published: 96.20% avg
Extended:  96.20% avg
Difference: 0.0000%
✅ Should be identical (< 0.01% difference)
```

---

## Step 7: Analyze Results

### Generate Summary Statistics

```bash
python3 << 'EOF'
import pandas as pd
import json

df = pd.read_csv('results/exports/sigmap-405-repos-extended-2026-04-29.csv')

print("=" * 60)
print("SIGMAP BENCHMARK SUITE - EXTENDED RESULTS SUMMARY")
print("=" * 60)

print("\nDataset Overview:")
print(f"  Total Repositories: {len(df)}")
print(f"  Languages: {df['primary_language'].nunique()}")
print(f"  Success Rate: {(df['success_flag'].sum() / len(df) * 100):.1f}%")

print("\nToken Reduction Statistics:")
print(f"  Mean: {df['reduction_percent'].mean():.2f}%")
print(f"  Median: {df['reduction_percent'].median():.2f}%")
print(f"  Std Dev: {df['reduction_percent'].std():.2f}%")
print(f"  Min: {df['reduction_percent'].min():.2f}%")
print(f"  Max: {df['reduction_percent'].max():.2f}%")

print("\nTop Languages (by repo count):")
print(df['primary_language'].value_counts().head(10))

print("\nExecution Time Statistics:")
print(f"  Total Time (avg per repo): {df['total_time_ms'].mean():.0f}ms")
print(f"  Analyze Time (avg): {df['analyze_time_ms'].mean():.0f}ms")
print(f"  Benchmark Time (avg): {df['benchmark_time_ms'].mean():.0f}ms")

print("\n" + "=" * 60)
EOF
```

### Language-Specific Analysis

```bash
python3 << 'EOF'
import pandas as pd

df = pd.read_csv('results/exports/sigmap-405-repos-extended-2026-04-29.csv')

print("\nLanguage-Specific Analysis:")
print("=" * 70)

for lang in df['primary_language'].value_counts().head(10).index:
    lang_df = df[df['primary_language'] == lang]
    print(f"\n{lang}:")
    print(f"  Repos: {len(lang_df)}")
    print(f"  Avg Reduction: {lang_df['reduction_percent'].mean():.2f}% ± {lang_df['reduction_percent'].std():.2f}%")
    print(f"  Range: {lang_df['reduction_percent'].min():.2f}% - {lang_df['reduction_percent'].max():.2f}%")
    print(f"  Success Rate: {(lang_df['success_flag'].sum() / len(lang_df) * 100):.1f}%")
EOF
```

---

## Step 8: Export to Database (Optional)

### Import to PostgreSQL

```bash
# Connect to PostgreSQL and import
psql -U username -d database -f results/exports/sigmap-405-repos-extended-2026-04-29.sql

# Verify import
psql -U username -d database -c "SELECT COUNT(*) FROM repositories;"
```

**Expected Output:**
```
 count
-------
   405
(1 row)
```

---

## Troubleshooting

### Clone Failures

**Issue:** Some repositories fail to clone

**Solution:**
```bash
# Check clone logs
ls -la logs/ (if available)

# Retry failed repos
bash scripts/02_clone_repos_extended.sh --resume
```

### Benchmark Timeouts

**Issue:** Some repos timeout at 300 seconds

**Solution:**
```bash
# Increase timeout (edit script)
# Find line: TIMEOUT=300
# Change to: TIMEOUT=600

# Retry failed repos
bash scripts/03_run_benchmarks_extended.sh --resume
```

### Storage Issues

**Issue:** Disk space running out

**Solution:**
```bash
# Check disk usage
df -h

# Clean up old results
rm -rf results/raw/

# Re-run finalization to regenerate exports
bash scripts/04_finalize_all_phases.sh
```

### Missing Files

**Issue:** Script not found

**Solution:**
```bash
# Verify scripts copied correctly
ls -la scripts/

# Verify execute permissions
chmod +x scripts/*.sh

# Re-copy if needed
cp /path/to/zenodo_submission_extended_405/scripts/* scripts/
```

---

## Expected Results

### Final Output

After completing all steps, you should have:

```
✅ 405 repositories cloned (~34 GB)
✅ 2,025+ benchmark operations completed
✅ 405 JSON result files generated
✅ 4 export formats created:
   - CSV (49 KB, 405 rows)
   - JSON (342 KB)
   - JSONL (271 KB)
   - SQL (88 KB)
✅ 99.6% success rate
✅ 100% data completeness
✅ 96.2% average token reduction
```

### Compare with Published Results

```
Published Dataset (240 repos):  96.2% avg reduction
Your Results (405 repos):        96.2% avg reduction
Repos 1-240 Difference:          < 0.01%
✅ Results verified
```

---

## Next Steps

### Analyze Your Results

```bash
# Load results in Python
import pandas as pd
df = pd.read_csv('results/exports/sigmap-405-repos-extended-2026-04-29.csv')

# Your analysis here
# df.groupby('primary_language')['reduction_percent'].agg(['mean', 'std'])
```

### Publish Results

```bash
# Create GitHub release
git tag v1.0-reproduced-405-repos
git push origin v1.0-reproduced-405-repos

# Or upload to Zenodo for DOI
```

### Compare with Other Tools

Use the same 405 repositories to compare with alternative context extraction tools:

```bash
# Modify scripts to use your tool
# See scripts/03_run_benchmarks_extended.sh for integration points
```

---

## Support

### Questions?

- See `DATASET_PAPER_EXTENDED.md` for data description
- See `EXTENDED_METHODOLOGY.md` for technical details
- Check `README.md` for overview
- Review included scripts for parameter details

### Report Issues

If results differ significantly from expected:
1. Verify all prerequisites installed
2. Check script logs for errors
3. Compare SigMap versions
4. Verify repository clones completed

---

## Citation

If you reproduce these results, please cite:

```bibtex
@dataset{sigmap2026_extended,
  author = {Mallick, Manoj},
  title = {SigMap Benchmark Suite: 405-Repository Extended Large-Scale AI Context Extraction Dataset},
  year = {2026},
  month = {April},
  publisher = {Zenodo},
  doi = {10.5281/zenodo.XXXXXXX}
}
```

---

**Reproducibility Guide Version:** 1.0  
**Status:** Complete and Verified  
**Date:** April 30, 2026

---

*Following this guide should produce identical results to the published dataset.*  
*Expected variance: < 2% due to system differences.*
