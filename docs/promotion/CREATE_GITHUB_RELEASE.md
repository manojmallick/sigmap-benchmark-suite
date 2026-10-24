# Create GitHub Release with DOI

**Dataset DOI:** https://doi.org/10.5281/zenodo.19899095  
**Repository:** sigmap-benchmark-suite  

---

## Step 1: Initialize Git & Create Repository (If Needed)

**Check if already a git repo:**
```bash
cd ~/Downloads/sigmap-benchmark-suite
git status
```

**If NOT a git repo, initialize:**
```bash
git init
git config user.name "Manoj Mallick"
git config user.email "manoj.mallick079@gmail.com"
```

**Check git status:**
```bash
git status
```

---

## Step 2: Create Initial Commit

If you have uncommitted changes:

```bash
# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: SigMap Benchmark Suite - 240 repositories, 1,775 operations"

# View commit
git log --oneline -1
```

---

## Step 3: Create Git Tag for Release

```bash
# Create version tag
git tag -a v1.0-240-repos -m "Release v1.0: 240-Repository SigMap Benchmark Suite

Dataset DOI: https://doi.org/10.5281/zenodo.19899095
Date: April 29, 2026
Status: Published to Zenodo with CC-BY-4.0 license"
```

**Verify tag created:**
```bash
git tag -l
```

---

## Step 4: Create GitHub Repository

1. Go to **https://github.com/new**
2. Fill in:
   - **Repository name:** `sigmap-benchmark-suite`
   - **Description:** "Large-Scale AI Context Extraction Benchmark - 240 repositories, 30+ languages, 96.2% average token reduction"
   - **Public:** ✅ (check this)
   - **Add README:** No (we have one)
   - **Add .gitignore:** Python (optional)
   - **License:** CC-BY-4.0 ✅ (select from dropdown)

3. Click **"Create repository"**

---

## Step 5: Connect Local Repo to GitHub

```bash
# Add remote origin (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/sigmap-benchmark-suite.git

# Verify remote
git remote -v
```

---

## Step 6: Push Code & Tag to GitHub

```bash
# Push main branch
git branch -M main
git push -u origin main

# Push the tag
git push origin v1.0-240-repos

# Verify (check GitHub, should see tag)
```

---

## Step 7: Create Release on GitHub

**Method 1: Via GitHub Web Interface (Easiest)**

1. Go to your repository on GitHub
2. Click **"Releases"** (right sidebar)
3. Click **"Create a new release"**
4. Select tag: **v1.0-240-repos**
5. Fill in release details (see template below)
6. Click **"Publish release"**

**Method 2: Via Command Line**

If you have `gh` CLI installed:

```bash
gh release create v1.0-240-repos \
  --title "SigMap Benchmark Suite v1.0 — 240 Repositories" \
  --notes "See RELEASE_NOTES.md for full details"
```

---

## Step 8: Release Notes Template

**Use this for the release description:**

```markdown
# SigMap Benchmark Suite v1.0 — 240-Repository Dataset

🎉 **First public release of the comprehensive AI context extraction benchmark**

## 📊 Dataset Highlights

- **240 open-source repositories** analyzed across 30+ programming languages
- **1,775 benchmark operations** with detailed metrics
- **96.2% average token reduction** (range: 76.5% to 99.99%)
- **50+ metadata fields** per repository
- **4 export formats:** CSV, JSON, JSONL, SQL
- **100% data integrity** verified

## 📚 What's Included

### Data Exports
- `sigmap-240-repos-2026-04-29.csv` — Tabular format for spreadsheets
- `sigmap-240-repos-2026-04-29.json` — Structured JSON format
- `sigmap-240-repos-2026-04-29.jsonl` — Streaming JSONL format
- `sigmap-240-repos-2026-04-29.sql` — PostgreSQL import script

### Documentation
- `Dataset_Paper.md` — Complete dataset paper (2,380 words)
- `Research_Paper.md` — Full research paper (7,120 words)
- `METHODOLOGY.md` — Complete methodology documentation
- `REPRODUCIBILITY.md` — How to reproduce the benchmark
- `scripts/` — All benchmark execution scripts

### Reproducibility
- `02_clone_repos_extended_500.sh` — Clone 240 repositories
- `03_run_benchmarks_extended.sh` — Execute 5 benchmark modes
- `04_finalize_all_phases.sh` — Aggregate results
- `export_academic_datasets.py` — Generate exports

## 🔬 Key Findings

**Language-Specific Patterns:**
- Python: 96.2% ± 1.8% (most consistent)
- JavaScript: 88–98% (high variability)
- Java: 94.5% ± 2.6%
- Go: 95.2% ± 2.1%

**Monorepo Analysis:**
- 45 monorepos identified (18.8%)
- JVM monorepos achieve exceptional compression (99.99%)
- Module-aware extraction improves by 2–3%

**Size vs. Performance:**
- No significant correlation between project size and reduction %
- Code organization matters more than absolute size
- Larger projects show better structure, enabling better compression

## 📦 Dataset Statistics

```
Total Repositories:        240
Total Languages:           30+
Total Benchmark Ops:       1,775
Total Source Files:        1,000,000+
Total Lines of Code:       500,000,000+
Success Rate:              99.6%
Data Quality:              100%
```

## 🔗 Data Access

**Published on Zenodo with permanent DOI:**

- **DOI:** https://doi.org/10.5281/zenodo.19899095
- **Zenodo Record:** https://zenodo.org/records/19899095
- **License:** Creative Commons Attribution 4.0 International (CC-BY-4.0)

## 📖 Citation

If you use this dataset in your research, please cite:

```bibtex
@dataset{sigmap2026,
  author = {Manoj Mallick},
  title = {SigMap Benchmark Suite: 240-Repository Large-Scale AI Context Extraction Dataset},
  year = {2026},
  publisher = {Zenodo},
  doi = {10.5281/zenodo.19899095},
  url = {https://zenodo.org/records/19899095}
}
```

**APA Format:**
```
SigMap Benchmark Suite. (2026). 240-repository large-scale AI context 
extraction dataset [Data set]. Zenodo. 
https://doi.org/10.5281/zenodo.19899095
```

## 📋 Contents

This release includes:
- ✅ Complete dataset (240 repos, 1,775 operations)
- ✅ All export formats (CSV, JSON, JSONL, SQL)
- ✅ Full reproducibility package (all scripts)
- ✅ Complete documentation (methodology, reproducibility guides)
- ✅ Both papers (dataset + research)
- ✅ Metadata (50+ fields per repository)

## 🔄 Reproducibility

To reproduce this benchmark:

1. Download this release
2. Follow `REPRODUCIBILITY.md`
3. Run `bash scripts/02_clone_repos_extended_500.sh` to clone repos
4. Run `bash scripts/03_run_benchmarks_extended.sh` to execute benchmarks
5. Run `bash scripts/04_finalize_all_phases.sh` to aggregate results

Expected time: ~2 hours on c2-standard-8 machine

## 🚀 Next Steps

- Research paper submitted to ACM TOSEM (May 2026)
- Community feedback welcome (GitHub issues)
- Future v2.0: 500+ repositories + temporal analysis planned

## 📞 Support

- **GitHub Issues:** Report bugs or request features
- **Zenodo Record:** Direct data download
- **Papers:** Read DATASET_PAPER.md and RESEARCH_PAPER.md for details

## 📄 License

This dataset is released under **Creative Commons Attribution 4.0 International (CC-BY-4.0)**

Attribution required. Commercial use permitted. See LICENSE file for details.

---

**Thank you for using SigMap Benchmark Suite! 🙏**

*First comprehensive large-scale AI context extraction benchmark across 30+ languages*
```

---

## Step 9: Verify Release on GitHub

1. Go to your GitHub repository
2. Click **"Releases"** tab
3. Should see **v1.0-240-repos** with your release notes
4. Files should be linked/downloadable

---

## Complete Command Sequence (Copy-Paste Ready)

If starting from scratch:

```bash
cd ~/Downloads/sigmap-benchmark-suite

# Initialize git
git init
git config user.name "Manoj Mallick"
git config user.email "manoj.mallick079@gmail.com"

# Stage and commit
git add .
git commit -m "Initial commit: SigMap Benchmark Suite - 240 repositories, 1,775 operations"

# Create tag
git tag -a v1.0-240-repos -m "Release v1.0: 240-Repository SigMap Benchmark Suite

Dataset DOI: https://doi.org/10.5281/zenodo.19899095
Published to Zenodo with CC-BY-4.0 license"

# Add GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/sigmap-benchmark-suite.git

# Push to GitHub
git branch -M main
git push -u origin main
git push origin v1.0-240-repos

# Verify
git remote -v
git tag -l
git log --oneline -1
```

---

## Key Points to Remember

✅ **Repository is public** (for maximum visibility)  
✅ **License is CC-BY-4.0** (matches Zenodo)  
✅ **DOI is clearly linked** in release notes  
✅ **All files included** (exports, scripts, papers)  
✅ **Release notes are comprehensive** (encourage reuse)  

---

## After Release is Created

1. Share the release URL: `https://github.com/YOUR_USERNAME/sigmap-benchmark-suite/releases/tag/v1.0-240-repos`
2. Link from Zenodo record back to GitHub
3. Link from papers to GitHub repository
4. Announce on social media with release URL

---

**Ready to create the release? Start with Step 1! 🚀**
