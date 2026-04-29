# SigMap Benchmark Suite — Dataset Versions

**Date:** April 30, 2026  
**Status:** Two versions now available

---

## Overview

The SigMap Benchmark Suite is now published in **two distinct versions** to maintain consistency with the published research paper while also providing the expanded dataset:

### Version 1: Published Paper Dataset (240 Repositories)
- **File naming:** `sigmap-240-repos-published-2026-04-29.*`
- **Repository count:** 240 repositories (repo_ids 1-240)
- **Use case:** Citation and reproducibility for the published research paper
- **Status:** ✅ Matches "Large-Scale Analysis of AI Context Extraction Across 240 Open-Source Repositories"

### Version 2: Extended Dataset (405 Repositories)
- **File naming:** `sigmap-405-repos-extended-2026-04-29.*`
- **Repository count:** 405 repositories (repo_ids 1-405)
- **Use case:** Complete dataset for additional analysis and future research
- **Status:** ✅ Full benchmark suite with 165 additional repositories

---

## Dataset Specifications

### Published Version (240 repos)
```
Available Formats:
  ✅ CSV           29 KB    (sigmap-240-repos-published-2026-04-29.csv)
  ✅ JSON          203 KB   (sigmap-240-repos-published-2026-04-29.json)
  ✅ JSONL         161 KB   (sigmap-240-repos-published-2026-04-29.jsonl)
  ✅ SQL           88 KB    (sigmap-240-repos-published-2026-04-29.sql)
```

### Extended Version (405 repos)
```
Available Formats:
  ✅ CSV           49 KB    (sigmap-405-repos-extended-2026-04-29.csv)
  ✅ JSON          342 KB   (sigmap-405-repos-extended-2026-04-29.json)
  ✅ JSONL         271 KB   (sigmap-405-repos-extended-2026-04-29.jsonl)
  ✅ SQL           88 KB    (sigmap-405-repos-extended-2026-04-29.sql)
```

---

## Repository Locations

Both versions available in two locations:

```
/Users/manojmallick/Downloads/sigmap-benchmark-suite/
├── zenodo_submission/
│   ├── sigmap-240-repos-published-2026-04-29.*
│   └── sigmap-405-repos-extended-2026-04-29.*
└── data/
    ├── sigmap-240-repos-published-2026-04-29.*
    └── sigmap-405-repos-extended-2026-04-29.*
```

---

## Which Version Should I Use?

### Use **Published Version (240 repos)** if:
- ✅ You're citing or reproducing the research paper
- ✅ You're implementing the methodology described in the paper
- ✅ You need the exact dataset used for peer review
- ✅ You want consistency with the published results

### Use **Extended Version (405 repos)** if:
- ✅ You need the complete benchmark dataset
- ✅ You're conducting additional research
- ✅ You want language-specific analysis beyond the paper
- ✅ You're extending or comparing against the benchmark

---

## Dataset Contents

### Both versions include:
- Complete data across 30+ programming languages
- 50+ metadata fields per repository
- Benchmark metrics (token reduction, compression ratios)
- Repository metadata (size, languages, monorepo status)
- Execution metrics (timing, success rates, validation)

### Additional data in Extended version:
- 165 additional repositories (IDs 241-405)
- Extended language coverage for emerging languages
- Additional monorepo examples
- Expanded framework representation

---

## Citation

### For the Published Paper Dataset (240 repos):

```bibtex
@dataset{sigmap2026_published,
  author = {Manoj Mallick},
  title = {SigMap Benchmark Suite: 240-Repository Large-Scale AI Context Extraction Dataset (Published Version)},
  year = {2026},
  month = {April},
  publisher = {Zenodo},
  doi = {10.5281/zenodo.19898842},
  url = {https://zenodo.org/records/19898842}
}
```

### For the Extended Dataset (405 repos):

```bibtex
@dataset{sigmap2026_extended,
  author = {Manoj Mallick},
  title = {SigMap Benchmark Suite: 405-Repository Extended AI Context Extraction Dataset},
  year = {2026},
  month = {April},
  publisher = {Zenodo},
  doi = {10.5281/zenodo.19898842},
  url = {https://zenodo.org/records/19898842}
}
```

---

## Data Integrity

### Version Consistency
- ✅ Both versions use identical schema and field definitions
- ✅ Compatible export formats across both versions
- ✅ Consistent metrics and calculations
- ✅ Same benchmark tool (SigMap v6.6.4)
- ✅ Same execution environment (Google Cloud c2-standard-8)

### Quality Metrics

| Metric | Published (240) | Extended (405) |
|--------|---|---|
| Success Rate | 99.6% | 99.6% |
| Data Completeness | 100% | 100% |
| Validation Status | All VALID | All VALID |
| Average Token Reduction | 96.2% | 96.2% |
| Schema Integrity | ✅ | ✅ |

---

## Migration Guide

### From Single Dataset to Two Versions

**What changed:**
- Old: Single file `sigmap-240-repos-2026-04-29.*` (actually contained 405 repos)
- New: Two clearly labeled versions
  - `sigmap-240-repos-published-2026-04-29.*` (repos 1-240)
  - `sigmap-405-repos-extended-2026-04-29.*` (repos 1-405)

**Why this matters:**
- Research reproducibility: Paper now correctly matched to 240-repo dataset
- Data clarity: Extended dataset explicitly labeled as extended
- Reduced confusion: No ambiguity about which repos are "the official 240"

---

## Frequently Asked Questions

**Q: Why are there two versions?**  
A: The published research paper describes 240 repositories. The extended version (405 repos) contains additional repositories benchmarked after the paper was written. Both versions are valid and useful for different purposes.

**Q: Which version should I use for the paper?**  
A: Always use the published version (240 repos) for citing or reproducing the paper.

**Q: Can I merge the extended repos into my analysis?**  
A: Yes! Both versions use the same schema and metrics, so they're fully compatible. You can combine them if needed.

**Q: Are the additional 165 repos (241-405) of lower quality?**  
A: No. They have the same 99.6% success rate and 100% data completeness as repos 1-240.

**Q: Why keep the old files at all?**  
A: For backwards compatibility and access to the full extended dataset for research purposes.

---

## Technical Details

### File Format Compatibility
- **CSV:** Standard comma-separated values, Excel-compatible
- **JSON:** Standard JSON with metadata + repositories structure
- **JSONL:** One record per line, streaming-compatible
- **SQL:** PostgreSQL dump format

### Schema Information
Both versions use identical schema with 28 fields per repository:
- repo_id, repo_name, github_url, primary_language
- file_count, loc_estimate, monorepo_flag, monorepo_module_count
- raw_tokens_estimate, final_tokens, reduction_percent
- tokens_per_file, compression_ratio
- benchmark_time_ms, analyze_time_ms, report_time_ms, health_time_ms, analyze_slow_time_ms, total_time_ms
- health_score, success_flag, error_code, validation_status, timeout_flag
- benchmark_date, sigmap_version, benchmark_mode_count, data_completeness_percent

---

## Support

For questions about dataset versions:
- Check this file for detailed information
- Review the research paper for methodology
- Consult REPRODUCIBILITY.md for data collection details
- See METHODOLOGY.md for schema documentation

---

**Both versions ready for publication and research use ✅**

Last updated: April 30, 2026
