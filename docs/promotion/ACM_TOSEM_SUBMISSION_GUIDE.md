# ACM TOSEM Manuscript Submission Guide

**Journal:** ACM Transactions on Software Engineering and Methodology (TOSEM)  
**Manuscript ID:** TOSEM-2026-0481  
**Status:** Requires reformatting and resubmission  
**Type:** Single-blind (authors identified, not anonymized)

---

## ✅ Checklist: What ACM Requires

### Author Information
- [ ] All authors listed on first page
- [ ] Full names (not anonymized)
- [ ] Author affiliations
- [ ] Corresponding author contact info
- [ ] ORCID numbers (optional but recommended)

### Manuscript Structure
- [ ] Title page with author info
- [ ] Abstract (150-250 words)
- [ ] Introduction
- [ ] Related Work
- [ ] Methodology
- [ ] Results & Analysis
- [ ] Discussion
- [ ] Conclusions
- [ ] Acknowledgments
- [ ] References
- [ ] Appendices (if needed)

### Formatting
- [ ] ACM template (Word or LaTeX)
- [ ] Single-blind (authors visible)
- [ ] Line numbers for review
- [ ] Page numbers
- [ ] Proper citation format
- [ ] Figure/table captions

### Submission Package
- [ ] Main manuscript (PDF)
- [ ] Supplementary materials (datasets, code)
- [ ] Cover letter
- [ ] Author declarations
- [ ] Conflict of interest statement

---

## 📝 Manuscript Structure for SigMap Paper

### **Title Page**
```
Title: Large-Scale Analysis of AI Context Extraction Across 240 Open-Source Repositories

Authors:
- Manoj Mallick, [Affiliation]
  Email: [email]
  ORCID: [if available]

Corresponding Author:
- Manoj Mallick
  Email: [email]
  Phone: [phone]

Acknowledgments:
[List collaborators, funding sources, etc.]
```

### **Abstract** (200-250 words)
```
Focus:
- Problem: Token limits in LLM context management
- Solution: SigMap - systematic evaluation of context extraction
- Dataset: 405 open-source repositories, 30+ languages
- Key findings: 96.2% token reduction, language patterns matter
- Contribution: Empirical foundation for context extraction research
- Data availability: CC-BY-4.0 licensed, publicly available

Keywords: Context extraction, LLM optimization, Code compression, 
Empirical software engineering, AI-assisted development
```

### **1. Introduction** (1000-1200 words)
```
Sections:
1.1 The Problem
    - LLM token limits
    - Context management challenge
    - Industry relevance

1.2 Motivation
    - Why context extraction matters
    - Gap in empirical knowledge
    - Opportunity for systematic study

1.3 Our Approach
    - Large-scale evaluation
    - 405 diverse repositories
    - Reproducible methodology

1.4 Key Contributions
    - Largest empirical study of context extraction
    - Language-specific patterns identified
    - Monorepo optimization insights
    - Complete reproducibility package

1.5 Paper Organization
```

### **2. Related Work** (800-1000 words)
```
Sections:
2.1 Context Management in LLMs
    - Token limits and their impact
    - Existing approaches
    - Limitations of current methods

2.2 Code Compression & Summarization
    - Prior work on code summarization
    - Token reduction techniques
    - Language-specific approaches

2.3 Empirical Software Engineering
    - Large-scale code analysis studies
    - Multi-language evaluation
    - Reproducibility in SE research

2.4 AI-Assisted Software Engineering
    - LLM integration in development
    - Context optimization
    - Tool effectiveness

2.5 Gap Analysis
    - What's missing from prior work
    - Why systematic study needed
    - Our contribution
```

### **3. Methodology** (1200-1500 words)
```
Sections:
3.1 Research Questions
    - RQ1: How effective is context extraction across languages?
    - RQ2: What factors affect compression rates?
    - RQ3: Can findings generalize?
    - RQ4: What's the practical impact?

3.2 Dataset & Repository Selection
    - Stratified sampling approach
    - 405 repositories selected
    - Language distribution
    - Size distribution
    - Diversity metrics

3.3 Execution Environment
    - Hardware specs (c2-standard-8)
    - Software stack
    - SigMap tool version
    - Network conditions

3.4 Benchmark Modes
    - Health check
    - Baseline measurement
    - Standard analysis
    - Comprehensive reporting
    - Deep analysis
    - Mode parameters

3.5 Metrics & Measurement
    - Token reduction percentage
    - Compression ratio
    - Execution time
    - Success rate
    - Data completeness

3.6 Quality Assurance
    - Validation procedures
    - Error handling
    - Data integrity checks
    - Reproducibility verification
```

### **4. Results** (1500-2000 words)
```
Sections:
4.1 Overall Statistics
    - 405 repositories analyzed
    - 2,025+ operations executed
    - 96.2% average token reduction
    - Success rate: 99.6%
    - Data completeness: 100%

4.2 Language-Specific Analysis
    - Python results (96.2% ± 1.8%)
    - JavaScript results (92.1% ± 4.2%)
    - Go, Rust, Java results
    - Comparative analysis
    - Statistical significance

4.3 Repository Size Analysis
    - Token reduction by size
    - Size doesn't predict compression
    - Other factors more important

4.4 Monorepo Analysis
    - 45 monorepos identified
    - Specialized handling impact
    - 2-3% improvement potential
    - Module count analysis

4.5 Framework Impact
    - Framework-specific patterns
    - React vs Vue (JavaScript)
    - Django vs FastAPI (Python)
    - Design pattern effects

4.6 Methodology Validation
    - Published (240) vs Extended (405) comparison
    - Identical 96.2% average
    - Findings generalize
    - Methodology robustness
```

### **5. Discussion** (800-1200 words)
```
Sections:
5.1 Interpretation of Findings
    - Language organization matters
    - Code idioms primary factor
    - Framework diversity effects
    - Size is not determinant

5.2 Implications for Researchers
    - Baseline for future work
    - Language-specific optimization
    - Research directions

5.3 Implications for Tool Builders
    - Realistic token reduction targets
    - Monorepo optimization opportunity
    - Language-specific strategies

5.4 Limitations
    - Shallow clones (depth=1)
    - Single execution run
    - Tool-specific results
    - Language detection limitations
    - 300-second timeout

5.5 Threats to Validity
    - Selection: diverse sampling
    - Measurement: documented metrics
    - Construct: multiple benchmark modes
    - Internal: controlled environment
    - External: 405 repos, 30+ languages

5.6 Generalizability
    - Findings hold across sample sizes
    - Multiple languages represented
    - Open-source + production repos
    - Different domains covered
```

### **6. Conclusions** (300-500 words)
```
- Summary of contributions
- Key findings recap
- Implications
- Future work opportunities
- Impact on field
```

### **7. Acknowledgments**
```
Funding sources
Collaborators
Tool authors (SigMap team)
Infrastructure providers
Community contributors
```

### **8. References** (30-50 citations)
```
Format: ACM style

Key papers to cite:
- LLM context management
- Code summarization
- Software engineering empirical studies
- Reproducible research
- AI-assisted development
```

### **9. Supplementary Materials** (Optional)
```
- Complete dataset (CSV, JSON, JSONL, SQL)
- Reproducibility scripts
- Hardware configuration details
- Language statistics
- Benchmark output samples
- Extended tables/charts
```

---

## 📋 ACM Formatting Requirements

### **Manuscript Format**
- Word: Use ACM Master Article Template
- LaTeX: Use acmart.cls class
- PDF: Single-column format
- Font: 10pt minimum
- Spacing: Double-spaced for review

### **Author Information**
```
First Author Name, Affiliation
Second Author Name, Affiliation
Corresponding Author: Name, Email, Phone
```

### **Headers & Footers**
- Page numbers: bottom center
- Running head: your short title
- Line numbers: for review version

### **Figures & Tables**
- High resolution (300+ DPI)
- Captions with descriptions
- References in text
- ACM-approved colors
- Legible fonts

### **Citations**
- ACM reference style
- Include DOIs when available
- Consistent formatting
- Complete author lists

---

## 🔗 References & Links

**ACM TOSEM:**
- Journal: https://tosem.acm.org/
- Author Guidelines: https://tosem.acm.org/authors.cfm
- Template Download: https://www.acm.org/publications/submission-templates

**ACM Style:**
- Reference style: https://www.acm.org/publications/authors/reference-formatting
- LaTeX class: https://ctan.org/pkg/acmart

**Supplementary:**
- Data deposit options: Zenodo, Figshare, GitHub
- Open science best practices: www.cos.io
- Reproducibility guidance: https://www.acm.org/publications/policies/artifact-review-and-badging-current

---

## 📝 Cover Letter Template

```
Dear Editor-in-Chief,

We are submitting a revised manuscript titled "Large-Scale Analysis of AI 
Context Extraction Across 240 Open-Source Repositories" for publication in 
ACM Transactions on Software Engineering and Methodology.

[Brief description of contribution]

This work:
- Provides empirical foundation for context extraction research
- Includes complete reproducible methodology
- Releases public dataset (CC-BY-4.0)
- Identifies language-specific optimization opportunities
- Validates findings across 240→405 repositories

All required materials are included:
✓ Reformatted manuscript (ACM template)
✓ Author information (non-anonymized)
✓ Complete datasets (CSV, JSON, JSONL, SQL)
✓ Reproducibility scripts
✓ Research papers (primary + extended)

We have no conflicts of interest to declare.

The authors are: [List all authors with affiliations]
Corresponding author: [Name, email, phone]

Thank you for considering this submission.

Sincerely,
Manoj Mallick
[Affiliation]
```

---

## ✅ Before Resubmitting: Checklist

### Formatting
- [ ] Used ACM template (not your own format)
- [ ] Non-anonymized (authors visible)
- [ ] Line numbers present
- [ ] Page numbers present
- [ ] 10pt+ font, readable
- [ ] All figures high resolution
- [ ] References in ACM format

### Content
- [ ] Abstract: 150-250 words
- [ ] Introduction: ~1000-1200 words
- [ ] Related work: ~800-1000 words
- [ ] Methodology: ~1200-1500 words
- [ ] Results: ~1500-2000 words
- [ ] Discussion: ~800-1200 words
- [ ] Conclusions: ~300-500 words
- [ ] References: 30-50 citations

### Submission Package
- [ ] Manuscript PDF
- [ ] Cover letter
- [ ] Author declarations
- [ ] Conflict of interest statement
- [ ] Supplementary materials
- [ ] Data availability statement

### Final Quality Check
- [ ] Spell check complete
- [ ] Grammar reviewed
- [ ] Citations verified
- [ ] Figures tested for clarity
- [ ] Tables readable
- [ ] All cross-references correct
- [ ] No anonymization present

---

## 🚀 Submission Steps

1. **Download ACM template** from https://www.acm.org/publications/submission-templates
2. **Reformat manuscript** using template
3. **Add author information** (non-anonymized)
4. **Prepare supplementary materials** (datasets, scripts)
5. **Write cover letter** (see template above)
6. **Final review** using checklist
7. **Submit** via TOSEM submission system
8. **Confirm receipt** from editorial office

**Expected review timeline:** 3-4 months

---

## 📞 Support Resources

- **ACM Support:** https://www.acm.org/publications/authors/
- **TOSEM Contact:** [Contact from email]
- **LaTeX Help:** acmtexsupport@aptaracorp.com
- **Style Issues:** Check recent TOSEM articles for format examples

---

**Ready to reformat and resubmit?** Use this guide to ensure compliance with ACM TOSEM requirements.
