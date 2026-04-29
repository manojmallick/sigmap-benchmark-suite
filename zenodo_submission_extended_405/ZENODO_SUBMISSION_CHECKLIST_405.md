# Zenodo Submission Checklist — Extended Dataset (405 Repositories)

**Extended Version with 165 Additional Repositories**  
**Primary Dataset Reference:** https://doi.org/10.5281/zenodo.19898842  
**Date:** April 30, 2026

---

## Pre-Submission Checklist

### Verify Files Ready
- [ ] `sigmap-405-repos-extended-2026-04-29.csv` (49 KB) — Present
- [ ] `sigmap-405-repos-extended-2026-04-29.json` (342 KB) — Present
- [ ] `sigmap-405-repos-extended-2026-04-29.jsonl` (271 KB) — Present
- [ ] `sigmap-405-repos-extended-2026-04-29.sql` (88 KB) — Present
- [ ] `README.md` — Present
- [ ] `EXTENDED_METHODOLOGY.md` — Present
- [ ] License information — Ready (CC-BY-4.0)

### Review Documentation
- [ ] README.md reviewed for completeness
- [ ] Dataset description accurate (405 repos, 30+ languages)
- [ ] Methodology properly documented
- [ ] Linked resource information prepared

### Prepare Account
- [ ] Zenodo account created or verified (https://zenodo.org)
- [ ] Email verified
- [ ] Profile complete
- [ ] ORCID linked (optional but recommended)

---

## Step 1: Go to Zenodo and Start Upload

1. Navigate to https://zenodo.org
2. Click **"Sign In"** (top right) or **"Sign Up"** if new
3. Log in with your account
4. Click **"Upload"** in the menu (or go to https://zenodo.org/deposit/new)

**Expected:** You see upload form

---

## Step 2: Select Publication Type

On the upload form:

1. **Communities:** Leave empty (or select relevant communities)
2. **Publication Type:** Select dropdown
3. Choose: **"Dataset"**
4. **Subtype:** "Research Data" or "Software Dataset"

**Expected:** Form adjusts to dataset-specific fields

---

## Step 3: Upload Files

### Method A: Drag and Drop (Easiest)
1. Drag all 4 data files onto upload area:
   - `sigmap-405-repos-extended-2026-04-29.csv`
   - `sigmap-405-repos-extended-2026-04-29.json`
   - `sigmap-405-repos-extended-2026-04-29.jsonl`
   - `sigmap-405-repos-extended-2026-04-29.sql`

2. Drag documentation files:
   - `README.md`
   - `EXTENDED_METHODOLOGY.md`

3. Wait for upload progress to complete

### Method B: Click to Select
1. Click "Choose files to upload"
2. Select files from your computer
3. Wait for upload to complete

**Expected:** Files appear in list with green checkmarks

---

## Step 4: Fill in Basic Metadata

### Title (REQUIRED)
```
SigMap Benchmark Suite: 405-Repository Extended Large-Scale AI Context Extraction Dataset
```

### Authors (REQUIRED)
```
Name: Manoj Mallick
Affiliation: (optional - leave blank or add organization)
```

Add more authors if applicable by clicking "Add author"

### Description (REQUIRED)
Copy and paste this:

```
Extended dataset version of the SigMap Benchmark Suite containing context extraction 
metrics across 405 diverse open-source repositories spanning 30+ programming languages.

This is the complete dataset including 165 additional repositories beyond the published 
240-repository dataset used in the peer-reviewed research paper.

Key Statistics:
- 405 open-source repositories across 30+ languages
- 2,025+ benchmark operations (5 modes per repository)
- Average token reduction: 96.2% (range: 76.5% to 99.99%)
- 50+ metadata fields per repository
- 100% data completeness and quality verification

Data Formats:
- CSV for spreadsheet analysis
- JSON for complete archival
- JSONL for streaming processing
- SQL for database import

See README.md for complete documentation.

Relationship: This extended version supplements the published 240-repository dataset
(https://doi.org/10.5281/zenodo.19898842) with 165 additional repositories benchmarked
after the research paper's publication.
```

---

## Step 5: Add Keywords

Click "Add keyword" and add these (one at a time):

- `AI Context Extraction`
- `Benchmark Suite`
- `Large Language Models`
- `Code Compression`
- `Programming Languages`
- `Token Optimization`
- `Software Engineering`
- `Empirical Benchmark`
- `405 Repositories`
- `Extended Dataset`

---

## Step 6: Set License

1. Scroll to "License" section
2. Click dropdown
3. Select: **"Creative Commons Attribution 4.0 International (CC-BY-4.0)"**

**Important:** Must match primary dataset's license

---

## Step 7: Set Access Level

1. Find "Access Rights" section
2. Select: **"Open Access"**
3. (Embargo option can be left blank)

**Expected:** Dataset will be publicly available immediately upon publication

---

## Step 8: Add Related Resources (CRITICAL)

This links the extended version to the primary published dataset.

1. Scroll to "Related/Alternate Identifiers" section
2. Click "Add Related Identifier"
3. Fill in:
   - **Identifier:** `10.5281/zenodo.19898842`
   - **Identifier Type:** `DOI`
   - **Relation Type:** Select `isSupplementedBy` (this dataset supplements the other)
   
4. Add description:
   ```
   Primary dataset: 240-repository version associated with the published research paper.
   This extended version includes those 240 repos plus 165 additional repositories.
   ```

5. Click "Add"

**Expected:** Related identifier appears in list

---

## Step 9: Add Subject Area (Optional but Recommended)

1. Click "Subjects" or "Classification"
2. Select primary subject:
   - **Field of Study:** Computer Science
   - **Subdomain:** Software Engineering
   
3. Add keywords if field appears again

---

## Step 10: Add Funding Information (If Applicable)

If this research was funded:

1. Click "Add funding"
2. Select funding agency
3. Enter grant number (if applicable)

Leave blank if no funding to declare.

---

## Step 11: Preview and Review

1. Scroll to bottom
2. Click **"Preview"** button
3. Review all information:
   - Title correct ✓
   - Authors correct ✓
   - Description complete ✓
   - Files present ✓
   - License: CC-BY-4.0 ✓
   - Access: Open ✓
   - Related resource linked ✓

4. If correct, proceed to next step
5. If changes needed, click "Edit" and correct

---

## Step 12: Publish (Final Step)

1. Click **"Publish"** button
2. Confirm: "Yes, I want to publish this upload"
3. Read terms of service
4. Check: "I've read and agree to the terms"
5. Click **"Publish"**

**Expected:** Page redirects to new record with DOI assigned

---

## Step 13: Record Your DOI

**IMPORTANT:** Copy and save your new DOI!

You will see something like:
```
Published! Your upload is now available at:
https://zenodo.org/records/XXXXXXX

DOI: 10.5281/zenodo.XXXXXXX
```

**Save this DOI for:**
- Dataset citation
- Updates to documentation
- Linking from related publications
- README and metadata updates

---

## After Publication

### Update Documentation

Once you have the DOI, update these files:

**In EXTENDED_README.txt:**
Replace `https://doi.org/10.5281/zenodo.XXXXXXX` with your actual DOI

**In ZENODO_SUBMISSION_CHECKLIST_405.md:**
Replace `XXXXXXX` with your actual DOI number

### Add to Your Repository

Create a file `ZENODO_DOI_EXTENDED.txt`:
```
Extended Dataset (405 Repositories)
DOI: 10.5281/zenodo.XXXXXXX
URL: https://zenodo.org/records/XXXXXXX
Published: April 30, 2026
```

### Link Back from Primary Dataset

Optionally, update the primary dataset record to link to this extended version:
1. Go to https://zenodo.org/records/19898842 (primary dataset)
2. Click "Edit" (if you have permissions)
3. Add related identifier pointing to this extended dataset
4. Save

---

## Verification Checklist (After Publication)

- [ ] DOI assigned: `10.5281/zenodo.XXXXXXX`
- [ ] Record publicly visible at Zenodo
- [ ] All 4 data files present
- [ ] Documentation files present
- [ ] License: CC-BY-4.0 ✓
- [ ] Access: Open ✓
- [ ] Related resource linked to primary dataset ✓
- [ ] Title includes "405 Repositories"
- [ ] Description mentions "Extended version"
- [ ] Keywords match submission
- [ ] Files downloadable as ZIP
- [ ] DOI resolves correctly

---

## Citation Format (Use After Publication)

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

### APA
```
SigMap Benchmark Suite. (2026). 405-repository extended large-scale AI context 
extraction dataset [Data set]. Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX
```

Replace `XXXXXXX` with your actual DOI number.

---

## Troubleshooting

### "File too large" error
All files (~750 KB total) are well below Zenodo's limit. If error occurs:
- Try again (temporary issue)
- Clear browser cache
- Try different browser
- Contact Zenodo support

### "Invalid metadata" error
- Verify title is not too long
- Check description doesn't contain special characters
- Ensure at least one author is listed
- License is properly selected

### "Can't link to related resource"
- Verify DOI is correct: `10.5281/zenodo.19898842`
- Use "DOI" as identifier type
- Make sure you selected a relation type
- Try re-entering without spaces

### Zenodo website down
- Check https://status.zenodo.org
- Wait and try again later
- Zenodo typically has 99.9% uptime

### Need to make changes after publishing
- Click "Edit" on published record
- Make changes (title, description, etc.)
- Click "Save"
- Changes publish immediately

---

## Support

### Zenodo Help
- Zenodo Help: https://zenodo.org/help
- Contact: support@zenodo.org
- FAQ: https://zenodo.org/faq

### This Dataset
- Questions: See README.md
- Methodology: See EXTENDED_METHODOLOGY.md
- Related Publication: Primary dataset DOI: https://doi.org/10.5281/zenodo.19898842

---

## Timeline

```
Pre-submission:    5 minutes (verify files, create account)
Upload process:    15 minutes (fill form, upload files)
Publishing:        1 minute (click publish)
─────────────────────────────────────────
Total time:        ~20 minutes

DOI Assignment:    Automatic (immediately upon publish)
Availability:      Immediate (open access)
Indexing:          Within 24 hours (search engines)
```

---

## Success Criteria

You're done when:
- ✅ DOI assigned
- ✅ Record publicly visible
- ✅ All files downloadable
- ✅ Related to primary dataset
- ✅ License: CC-BY-4.0
- ✅ Can cite with DOI
- ✅ URL works: https://zenodo.org/records/XXXXXXX

---

## Final Notes

- **Primary Dataset:** https://doi.org/10.5281/zenodo.19898842 (240 repos)
- **This Dataset:** Extended version (405 repos) — NEW DOI will be assigned
- **Relationship:** Repos 1-240 in both, Repos 241-405 only in extended version
- **Files:** Both versions use identical schema, metrics, and export formats

---

**Ready to submit? Start at Step 1: Go to Zenodo**

**Estimated time from now: ~20 minutes to published DOI**

Good luck! 🚀

---

*Last Updated: April 30, 2026*
