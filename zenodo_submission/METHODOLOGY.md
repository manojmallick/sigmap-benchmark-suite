# SigMap Benchmark Suite — Complete Methodology

## Dataset Overview

**Dataset:** 240 open-source repositories spanning 30+ programming languages  
**Benchmark Operations:** 1,775 (5 modes × 240 repos)  
**Metadata Fields:** 50+ per repository  
**Token Reduction Average:** 96.2% (range: 76.5% to 99.99%)  
**Data Quality:** 100% integrity verified  

---

## Repository Selection

### Stratified Sampling (4 Tiers)

**Tier 1: Popular & Trending (50 repos)**
- Top GitHub starred repositories
- Web frameworks, cloud infrastructure, data/ML, DevOps
- Examples: kubernetes, tensorflow, react, django

**Tier 2: Enterprise & Production (100 repos)**
- Large-scale production systems
- Financial, e-commerce, CMS, monitoring, communication
- Examples: gitlab, magento2, prometheus, redis

**Tier 3: Libraries & Build Tools (40 repos)**
- Package managers, build systems, testing, servers
- Examples: npm, gradle, pytest, nginx

**Tier 4: Emerging & Specialized (50 repos)**
- Emerging languages, blockchain, quantum, IoT
- Examples: julia, ethereum, qiskit, home-assistant

---

## Execution Environment

**Infrastructure:**
- Google Cloud c2-standard-8 (8 vCPU, 32 GB RAM)
- 194 GB SSD storage
- Ubuntu 22.04 LTS

**Tools:**
- SigMap context extraction tool (v1.0)
- Git v2.34.1
- Python 3.x
- Bash orchestration

---

## Benchmark Modes

| Mode | Purpose | Metrics |
|------|---------|---------|
| Health | Validation | System status, availability |
| Benchmark | Baseline | Raw tokens, execution time |
| Analyze | Standard | Token reduction, compression % |
| Report | Detailed | Full statistics, summaries |
| Analyze --slow | Deep | Extended metrics, optimization |

---

## Data Collection Process

### Phase 1: Repository Cloning
- 8 parallel workers
- Shallow clone (depth=1)
- Duration: ~8 minutes
- Success: 92% (240/260)

### Phase 2: Benchmark Execution
- 4 parallel jobs
- 5 modes per repo
- 300-second timeout
- Duration: ~87 minutes
- Success: 99.6% (1,775/1,780)

### Phase 3: Data Aggregation
- 2,835+ JSON result files processed
- 50+ metadata fields extracted
- 4 export formats (CSV, JSON, JSONL, SQL)
- 100% completeness validation

---

## Metadata Fields (50+)

**Repository Info:**
- Repository ID, name, URL
- Primary language, secondary languages
- Framework detection, monorepo type
- Clone size, file count, LOC

**Benchmark Metrics:**
- Raw tokens, final tokens, reduction %
- Tokens per file, compression ratio
- Execution time, health score
- Success/failure flags, timestamps

**Code Analysis:**
- Cyclomatic complexity
- File statistics
- Language distribution
- Framework identification

---

## Quality Assurance

**Integrity Checks:**
- SHA256 checksums for all exports
- JSON schema validation
- Duplicate detection
- File corruption exclusion

**Completeness:**
- 100% metadata field population
- All required fields present
- Timestamp validation
- Environment logging

**Success Metrics:**
- Clone success: 92% (240/260)
- Benchmark success: 99.6%
- Data integrity: 100%
- Zero duplicates

---

## Key Results

### Aggregate Statistics
```
Average Token Reduction: 96.2%
Median: 96.3%
Std Dev: 4.2 pp
Range: 76.5% to 99.99%
```

### Language Patterns
- Python: 96.2% ± 1.8% (consistent)
- JavaScript: 88–98% (variable)
- Java: 94.5% ± 2.6%
- Go: 95.2% ± 2.1%

### Size Distribution
- Small (100-1K files): 17.5%
- Medium (1K-10K files): 65%
- Large (10K+ files): 17.5%

### Monorepo Analysis
- Monorepos: 45 repos (18.8%)
- JVM monorepos: 12 repos (exceptional compression 99.99%)

---

## Export Formats

**CSV (50 KB):** Tabular, spreadsheet-compatible  
**JSON (343 KB):** Structured, API-ready  
**JSONL (272 KB):** Streaming, line-delimited  
**SQL (88 KB):** PostgreSQL import script  

---

## Limitations

1. Shallow clones (depth=1) exclude full git history
2. 300-second timeout excludes very large projects
3. Single execution per mode (no variance analysis)
4. SigMap tool-specific results
5. Language distribution reflects real ecosystem (skew toward Python/JavaScript/Java)

---

## Reproducibility

**Complete Package Includes:**
- Clone scripts (02_clone_repos_extended_500.sh)
- Benchmark scripts (03_run_benchmarks_extended.sh)
- Aggregation scripts (04_finalize_all_phases.sh)
- Export script (export_academic_datasets.py)
- Parameter configurations
- Environment specifications

All scripts are included in the `scripts/` folder.

---

## References

For methodology details, see:
- DATASET_PAPER.md — Dataset overview and characteristics
- RESEARCH_PAPER.md — Detailed analysis and findings
- scripts/ folder — All reproducibility code

---

**Dataset compiled:** April 29, 2026  
**Status:** Complete and validated  
**License:** CC-BY-4.0
