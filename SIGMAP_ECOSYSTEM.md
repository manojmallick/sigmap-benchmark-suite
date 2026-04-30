# SigMap Ecosystem — Tool + Benchmark Suite + Docs

Complete overview of the SigMap project ecosystem and how the components fit together.

---

## 🌍 The Three Components

### 1. **SigMap Tool** (Original Repository)
**URL:** https://github.com/manojmallick/sigmap

The actual context extraction tool that powers everything.

**What it does:**
- Analyzes source code
- Extracts semantic signatures
- Compresses code for LLM consumption
- Produces token reduction metrics

**Key features:**
- Multi-language support (30+ languages)
- 5 benchmark modes
- Real-time analysis
- Production-ready

**Who uses it:**
- Developers building AI tools
- Researchers evaluating context strategies
- Teams integrating LLM into workflows

---

### 2. **SigMap Benchmark Suite** (This Project)
**URL:** https://github.com/manojmallick/sigmap-benchmark-suite

Large-scale empirical evaluation using the SigMap tool.

**What it includes:**
- 405 open-source repositories analyzed
- 2,025+ benchmark operations
- Complete datasets (4 formats)
- Research papers + methodology
- Reproducibility scripts
- All code CC-BY-4.0 licensed

**Key findings:**
- 96.2% average token reduction
- Language patterns matter more than size
- Monorepos offer 2-3% improvement opportunity
- Results validated at scale

**Who uses it:**
- Researchers studying context extraction
- Tool developers benchmarking tools
- Academic teams doing empirical studies
- Companies evaluating feasibility

---

### 3. **SigMap Documentation**
**URL:** https://manojmallick.github.io/sigmap/

Complete documentation for the SigMap project.

**What it covers:**
- Tool installation and setup
- Usage examples
- API documentation
- Configuration options
- Performance benchmarks
- Best practices
- Integration guides

**Who uses it:**
- Developers integrating SigMap
- Teams setting up in production
- Researchers extending the tool
- Students learning the methodology

---

## 🔗 How They Connect

```
┌─────────────────────────────────────────────────────────────┐
│                    SigMap Ecosystem                         │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐
│   SigMap Tool    │         │   Docs Site      │
│  (Original Repo) │         │  (User Guide)    │
│     github.com/  │         │   manojmallick.  │
│    manojmallick/ │         │   github.io/     │
│     sigmap       │         │   sigmap/        │
│                  │         │                  │
│ ✓ Codebase      │◄────────┤ ✓ Setup guide   │
│ ✓ Algorithms    │         │ ✓ Examples      │
│ ✓ Implementation│         │ ✓ API docs      │
│ ✓ Features      │         │ ✓ Integration   │
└────────┬─────────┘         └──────────┬──────┘
         │                              │
         │ Used by                      │ Documents
         │                              │
         └──────────────┬───────────────┘
                        │
                        ▼
        ┌────────────────────────────────┐
        │  SigMap Benchmark Suite        │
        │  (This Project)                │
        │  github.com/manojmallick/      │
        │  sigmap-benchmark-suite        │
        │                                │
        │ ✓ 405 repos analyzed           │
        │ ✓ 2,025+ operations            │
        │ ✓ Research papers              │
        │ ✓ Complete datasets            │
        │ ✓ Reproducibility scripts      │
        │ ✓ Findings & insights          │
        └────────────────────────────────┘
```

---

## 📊 Relationship Table

| Aspect | SigMap Tool | Benchmark Suite | Docs |
|--------|---|---|---|
| **Repository** | github.com/manojmallick/sigmap | github.com/manojmallick/sigmap-benchmark-suite | manojmallick.github.io/sigmap/ |
| **Type** | Tool/Software | Dataset/Research | Documentation |
| **Primary Use** | Extract context from code | Evaluate effectiveness | Learn & integrate |
| **Audience** | Developers, Researchers | Researchers, Teams | All users |
| **Key Content** | Algorithms, Code | Data, Papers, Scripts | Guides, Examples |
| **License** | [Check repo] | CC-BY-4.0 | CC-BY-4.0 |
| **Updates** | Ongoing development | Published dataset | Maintained |

---

## 🎯 User Journey

### **I want to extract code context...**
→ Start at **Documentation** (setup, examples)  
→ Install **SigMap Tool**  
→ (Optional) Compare with **Benchmark Suite**

### **I want to evaluate context extraction...**
→ Download **Benchmark Suite** dataset  
→ Read research papers  
→ (Optional) Learn tool at **Documentation**

### **I want to build tools using SigMap...**
→ Read **Documentation** (API, integration)  
→ Install **SigMap Tool**  
→ Benchmark against **Benchmark Suite**  
→ Contribute back

### **I want to do research on context extraction...**
→ Download **Benchmark Suite** (405 repos, papers)  
→ Use scripts to analyze  
→ (Optional) Extend using **SigMap Tool**  
→ Cite both repos

---

## 🔗 Links to Include in Announcements

### **In Every Announcement:**
```
SigMap Ecosystem:
  📦 Tool:           https://github.com/manojmallick/sigmap
  📚 Docs:           https://manojmallick.github.io/sigmap/
  📊 Benchmark:      https://github.com/manojmallick/sigmap-benchmark-suite
```

### **In Technical Posts:**
```
For implementation details:
→ Check the SigMap Tool repository
→ Read the docs: https://manojmallick.github.io/sigmap/

For evaluation & research:
→ Use Benchmark Suite: github.com/manojmallick/sigmap-benchmark-suite
```

### **In Academic Content:**
```
Cite:
[1] SigMap Tool: github.com/manojmallick/sigmap
[2] Benchmark Suite: github.com/manojmallick/sigmap-benchmark-suite
[3] Documentation: manojmallick.github.io/sigmap/
[4] Primary Dataset DOI: https://doi.org/10.5281/zenodo.19898842
```

---

## 📝 How to Reference in Posts

### **For LinkedIn/Professional:**
```
"The SigMap ecosystem includes the tool (github.com/manojmallick/sigmap), 
comprehensive documentation (manojmallick.github.io/sigmap/), and now the 
large-scale benchmark suite (this project)."
```

### **For Twitter/X:**
```
SigMap ecosystem now complete:
📦 Tool: github.com/manojmallick/sigmap
📚 Docs: manojmallick.github.io/sigmap/
📊 Benchmark (405 repos): github.com/manojmallick/sigmap-benchmark-suite

Everything you need for context extraction research.
```

### **For GitHub:**
```
## SigMap Ecosystem

This is one part of the larger SigMap ecosystem:

- **SigMap Tool** — The context extraction tool  
  https://github.com/manojmallick/sigmap

- **SigMap Benchmark Suite** — Large-scale evaluation (this repo)  
  https://github.com/manojmallick/sigmap-benchmark-suite

- **SigMap Docs** — Complete documentation & guides  
  https://manojmallick.github.io/sigmap/

All components are open-source and complement each other.
```

### **For Academic/Research:**
```
SigMap Project Overview:
1. Tool Repository (github.com/manojmallick/sigmap)
   - Implementation and algorithms
   
2. Benchmark Suite (github.com/manojmallick/sigmap-benchmark-suite)
   - Empirical evaluation across 405 repos
   - Complete datasets and reproducibility
   
3. Documentation (manojmallick.github.io/sigmap/)
   - Integration guides
   - Usage examples
   - Best practices

For context extraction research, all three are complementary.
```

---

## 🚀 Getting Started with SigMap Ecosystem

### **Path 1: I want to USE SigMap**
1. Go to Docs: https://manojmallick.github.io/sigmap/
2. Follow installation guide
3. Try examples
4. Integrate into your workflow

### **Path 2: I want to EVALUATE SigMap**
1. Go to Benchmark Suite: https://github.com/manojmallick/sigmap-benchmark-suite
2. Download dataset (405 repos)
3. Read research papers
4. Run reproducibility scripts
5. Compare with your own tools

### **Path 3: I want to EXTEND SigMap**
1. Go to Tool repo: https://github.com/manojmallick/sigmap
2. Review documentation: https://manojmallick.github.io/sigmap/
3. Study the codebase
4. Implement extensions
5. Benchmark against Suite

### **Path 4: I want to do RESEARCH**
1. Download Benchmark Suite: https://github.com/manojmallick/sigmap-benchmark-suite
2. Read papers (RESEARCH_PAPER_EXTENDED.md, etc.)
3. Analyze datasets
4. Use Tool for new analysis if needed
5. Publish findings, cite repos

---

## 📦 What Each Component Offers

### **SigMap Tool**
```
✓ Production-ready context extraction
✓ Multi-language support (30+ languages)
✓ 5 benchmark modes
✓ Configurable parameters
✓ Real-time analysis
✓ Integration-friendly API
✓ Active development
```

### **Benchmark Suite**
```
✓ 405 analyzed repositories
✓ 2,025+ benchmark operations
✓ Complete datasets (4 formats)
✓ Research papers
✓ Reproducibility scripts
✓ Methodology documentation
✓ Quality metrics (99.6% success)
```

### **Documentation**
```
✓ Installation guide
✓ Quick start tutorial
✓ API reference
✓ Configuration options
✓ Integration examples
✓ Performance benchmarks
✓ Best practices
✓ Troubleshooting guide
```

---

## 🔀 Cross-Repository Links

**In SigMap Tool (github.com/manojmallick/sigmap):**
- Link to Benchmark Suite for evaluation
- Link to Docs for usage
- Link to ecosystem overview

**In Benchmark Suite (github.com/manojmallick/sigmap-benchmark-suite):**
- Link to Tool for implementation details
- Link to Docs for context
- Show how dataset was generated

**In Documentation (manojmallick.github.io/sigmap/):**
- Link to Tool source code
- Link to Benchmark Suite for metrics
- Show ecosystem integration

---

## 📊 Ecosystem Stats

| Component | Repositories | Code Files | Data Size | Format |
|-----------|---|---|---|---|
| **Tool** | 1 (main) | ~50-100 | ~500KB | Source code |
| **Benchmark Suite** | 405 (evaluated) | 1.6M+ | 750KB | Dataset exports |
| **Docs** | 1 (site) | ~20-30 | ~100KB | Markdown + HTML |

---

## 🎯 Announcement Key Message

```
"The SigMap ecosystem is now complete:

🔧 SigMap Tool — Production-ready context extraction
https://github.com/manojmallick/sigmap

📖 SigMap Docs — Complete integration guide
https://manojmallick.github.io/sigmap/

📊 SigMap Benchmark Suite — Large-scale evaluation (405 repos)
https://github.com/manojmallick/sigmap-benchmark-suite

All components are open-source, fully documented, and ready for use.
"
```

---

## 💡 Why This Matters

1. **Complete Solution** — Tool + evaluation + documentation
2. **Easy Entry** — Multiple ways to start depending on your needs
3. **Credible Research** — Benchmark Suite validates tool effectiveness
4. **Community Support** — Documentation ensures successful adoption
5. **Reproducible** — Everything open-source and documented

---

## Next Steps

1. Update all announcement files to include ecosystem links
2. Add ecosystem overview to main README
3. Cross-link repositories (Tool ↔ Benchmark ↔ Docs)
4. Include ecosystem in all platform announcements
5. Update GitHub profiles to reflect ecosystem

**Result:** Cohesive project presentation across all platforms
