# Submit Research Paper to Academic Venues

**Papers Ready:** RESEARCH_PAPER_FINAL.md (7,120 words)  
**Dataset DOI:** https://doi.org/10.5281/zenodo.19899095  
**Target Venues:** ACM TOSEM, IEEE Software, ICSE  

---

## Option 1: ACM TOSEM (Recommended First)

**Venue:** ACM Transactions on Software Engineering and Methodology  
**Impact:** Top-tier software engineering venue  
**Timeline:** 3-4 months review  
**Acceptance Rate:** ~20-25%

### Step 1: Prepare Paper for TOSEM

Your paper needs:
- ✅ Abstract (200-250 words) — Already have
- ✅ Introduction (1,000-1,200 words) — Already have
- ✅ Methodology (1,200-1,500 words) — Already have
- ✅ Results & Analysis (2,000-2,500 words) — Already have
- ✅ Discussion (800-1,000 words) — Already have
- ✅ References (30-50 citations) — Need to complete
- ✅ Data Availability — Already added

### Step 2: Create Account at ACM

1. Go to **https://authors.acm.org/**
2. Click "Create Account"
3. Fill in your details:
   - Name: Manoj Mallick
   - Email: manoj.mallick079@gmail.com
   - Affiliation: [Your Organization]
4. Verify email
5. Create login password

### Step 3: Start New Submission

1. Log in to https://authors.acm.org/
2. Click "New Submission"
3. Select:
   - Journal: **ACM Transactions on Software Engineering and Methodology**
   - Article Type: **Research Article**
   - Category: **Software Engineering**

### Step 4: Fill Submission Form

**Manuscript Title:**
```
Large-Scale Analysis of AI Context Extraction Across 240 Open-Source Repositories
```

**Abstract (copy from paper):**
```
Effective context management represents a critical challenge in utilizing large 
language models (LLMs) for software engineering tasks. Token limits enforce hard 
constraints on the amount of code context available for analysis, creating a 
fundamental trade-off between comprehensiveness and efficiency. We present SigMap, 
a comprehensive evaluation of context extraction strategies across 240 diverse 
open-source repositories spanning 30+ programming languages...
```

**Keywords:**
```
Context Extraction, LLM Optimization, Code Compression, Programming Languages, 
Software Engineering Tools, AI-Assisted Development, Empirical Software Engineering
```

**Author Information:**
- Name: Manoj Mallick
- Email: manoj.mallick079@gmail.com
- Affiliation: [Your Organization]

**Research Statement (150 words max):**
```
This work presents the first comprehensive, large-scale empirical evaluation of 
context extraction effectiveness across 240 diverse open-source repositories and 
30+ programming languages. Through 1,775 benchmark operations, we demonstrate 
that language-specific patterns, monorepo structures, and code organization 
determine compression effectiveness more than project size. The dataset enables 
researchers to develop improved context extraction strategies and provides an 
empirical foundation for AI-assisted software engineering research.
```

### Step 5: Upload Manuscript

**File Format:** PDF (preferred for academic submission)

To convert your markdown to PDF:
```bash
# Install pandoc if not already installed
brew install pandoc

# Convert markdown to PDF
pandoc Research_Paper.md -o Research_Paper.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=1in \
  -V fontsize=12pt
```

Or use online converter: https://pandoc.org/try/

**Upload Steps:**
1. Click "Upload Manuscript"
2. Select PDF file
3. Confirm upload
4. File should show as "Accepted" (green checkmark)

### Step 6: Upload Supplementary Materials

ACM allows supplementary files. Upload:
- METHODOLOGY.md
- REPRODUCIBILITY.md
- Dataset paper (Dataset_Paper.md)

**Label as:** "Supplementary Materials — Methodology and Reproducibility"

### Step 7: Add Dataset Information

In the submission form, add:

**Data Availability Statement:**
```
The SigMap Benchmark Suite dataset and all reproducibility materials are 
publicly available on Zenodo:

DOI: https://doi.org/10.5281/zenodo.19899095
URL: https://zenodo.org/records/19899095
License: Creative Commons Attribution 4.0 International (CC-BY-4.0)

The dataset includes:
- Complete data exports in 4 formats (CSV, JSON, JSONL, SQL)
- All benchmark operation results
- Full reproducibility package (scripts, configurations, parameters)
- Detailed methodology and documentation

All materials are available for community use under CC-BY-4.0 license.
```

### Step 8: Submit

1. Review all information
2. Agree to copyright/publishing terms
3. Click **"Submit"**
4. You'll get confirmation email with manuscript number

---

## Option 2: IEEE Software (Alternative)

**Venue:** IEEE Software  
**Impact:** Mid-tier software engineering venue  
**Timeline:** 2-3 months review  
**Acceptance Rate:** ~25-30%

### Quick Steps:

1. Go to **https://www.computer.org/csdl/journal/so**
2. Click "Submit an Article"
3. Follow similar steps as ACM
4. Upload PDF (same process)
5. Add data availability statement

---

## Option 3: ICSE (Conference)

**Venue:** International Conference on Software Engineering  
**Impact:** Top-tier conference  
**Timeline:** Varies by deadline (usually 2-3 months)  
**Acceptance Rate:** ~15-20%

### Quick Steps:

1. Check **https://conf.researchr.org/home/icse-2027** for current deadline
2. Format paper per ICSE guidelines (usually ACM format)
3. Submit through EasyChair or designated system
4. Same supplementary materials as ACM

---

## Recommended Submission Order:

1. **First:** ACM TOSEM (highest impact, most prestigious)
   - If accepted → great! Done
   - If rejected → within 1 week, submit to IEEE Software

2. **Second:** IEEE Software (if TOSEM rejected)
   - If accepted → good fit
   - If rejected → submit to ICSE

3. **Third:** ICSE (if others rejected)
   - Conference format, different audience
   - Good fallback option

---

## Before You Submit:

**Checklist:**
- [ ] Complete references (at least 30-40 citations)
- [ ] Add all figures/tables with captions
- [ ] Ensure all citations have DOI or URL
- [ ] Proofread for typos
- [ ] Check for consistency in formatting
- [ ] Verify all section numbers are correct
- [ ] Include data availability statement with DOI
- [ ] Convert to PDF for submission

---

## Expected Timeline:

```
Day 1:     Submit to ACM TOSEM
Day 7-14:  Editor assigns reviewers
Week 4-6:  Get reviews
Week 8:    Hear acceptance/rejection decision
```

**If rejected:** Resubmit to IEEE within 1 week (same paper, minimal changes if needed)

---

## Help with References:

Your paper mentions these - make sure to add full citations:

**LLM Context & Prompting:**
- Brown et al. 2020 - Language Models are Few-Shot Learners
- Raffel et al. 2020 - Exploring Limits of Transfer Learning
- Wei et al. 2022 - Chain-of-Thought Prompting

**Code Compression:**
- Iyer et al. 2016 - Summarizing Source Code
- Allamanis & Sutton 2013 - Variable Names

**Multi-Language Studies:**
- Meyerovich & Rabkin 2013 - Language Adoption
- Ray et al. 2014 - Programming Languages & Code Quality

---

## Support

**ACM Submissions:** https://authors.acm.org/support  
**IEEE Submissions:** https://www.computer.org/publications/author-support  
**ICSE Submissions:** https://conf.researchr.org/track/icse-2027/icse-2027-research

---

**Ready to submit? Start with ACM TOSEM at https://authors.acm.org/**

You can do it! 🚀
