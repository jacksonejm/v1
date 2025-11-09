# Phase 0.1: Snowflake Deployment Guide

**Status:** ⏳ **ACTION REQUIRED - Manual Snowflake Upload**
**Estimated Time:** 30-45 minutes
**Prerequisites:** Snowflake admin access to ONET_CAREER_DB

---

## Overview

To complete Phase 0.1 (Canadian NOC Integration), you need to:
1. ✅ Upload 11 CSV files to Snowflake stage
2. ✅ Run 3 SQL scripts
3. ✅ Validate data import

---

## Step 1: Upload CSV Files (15 minutes)

### Option A: Snowsight Web UI (Recommended)

1. **Login to Snowflake** at [https://app.snowflake.com](https://app.snowflake.com)

2. **Navigate to Stage:**
   ```
   Data > Databases > ONET_CAREER_DB > CAREER_SCHEMA > Stages > NOC_STAGE
   ```

3. **Click "Upload Files"**

4. **Select these 11 files** from your local machine:

   **Crosswalk (from `NOC/Cross/`):**
   - `noc2021_onet26.csv` (1,466 mappings)

   **OaSIS Data (from `NOC/`):**
   - `0131ca04-0379-4c1f-b814-05fb139b9718.csv` (Interests EN)
   - `7941081c-a0ce-4add-aa2c-74aa96b1c57f.csv` (Interests FR)
   - `8cc1bd89-afa1-4cfe-b45a-d6511d9318d7.csv` (Lead Statements EN)
   - `381efe24-1b50-4a18-b6bb-cb7d0fa0921f.csv` (Lead Statements FR)
   - `053f7e1c-e629-432e-a70f-ed043e028f65.csv` (Employment Requirements EN)
   - `e080bd8a-a760-488d-81f8-e6e6f50c6396.csv` (Employment Requirements FR)
   - `66414d34-029e-4d0e-b6e5-ae3d99a73fac.csv` (Example Titles EN)
   - `e3599639-3540-4d39-a42b-f7d41909d6d4.csv` (Example Titles FR)
   - `79361933-2793-4e1e-b255-b6fa214ef28d.csv` (Main Duties EN)
   - `0553ee55-1a87-4709-bd61-3739af0322a3.csv` (Main Duties FR)

5. **Click "Upload"** and wait for completion

6. **Verify upload:**
   ```sql
   LIST @NOC_STAGE;
   ```
   Expected: 11 files listed

---

## Step 2: Run SQL Import Scripts (10-15 minutes)

Open Snowflake **Worksheets** and run these scripts in order:

### Script 1: Import Crosswalk (3-5 minutes)

File: `NOC_STEP1_IMPORT_CROSSWALK.sql`

**Run entire script** - it will:
- Create `NOC_STAGE` (if not exists)
- Create `NOC_ONET_CROSSWALK` table
- Load 1,466 NOC→O*NET mappings
- Validate data quality

**Expected Output:**
```
✅ Table created: NOC_ONET_CROSSWALK
✅ Rows imported: 1466 mappings
✅ Unique NOC codes: 515
✅ Unique O*NET codes: 952
✅ Coverage: 94.0%
```

### Script 2: Import OaSIS Display Data (5-8 minutes)

File: `NOC_STEP2_IMPORT_OASIS_DISPLAY.sql`

**Run entire script** - it will:
- Create `NOC_OCCUPATIONS` table
- Load 900 Canadian occupation records
- Import bilingual titles, descriptions, requirements, duties

**Expected Output:**
```
✅ Table created: NOC_OCCUPATIONS
✅ Rows imported: 900 occupations
✅ Coverage: 900/900 (100%)
✅ Bilingual: 900 EN titles, 900 FR titles
```

### Script 3: Validation Queries (2-3 minutes)

File: `NOC_STEP3_VALIDATION_QUERIES.sql`

**Run entire script** - it will validate:
- Crosswalk data integrity
- OaSIS data completeness
- Key occupation lookups
- Enrichment coverage for top 50 careers

**Expected Output:**
- ✅ All validation checks pass
- ✅ 85-95% of top careers have NOC enrichment
- ✅ Performance tests < 100ms

---

## Step 3: Verify Success (2 minutes)

Run this quick verification query:

```sql
-- Test Recipe D v4.0 + NOC enrichment
SELECT
    cfv.ONET_SOC_CODE,
    cfv.JOB_TITLE AS onet_title,
    c.NOC_CODE,
    n.TITLE_EN AS canadian_title,
    c.MAPPING_CONFIDENCE
FROM CAREER_FULL_VECTORS cfv
LEFT JOIN NOC_ONET_CROSSWALK c ON cfv.ONET_SOC_CODE = c.ONET_CODE
LEFT JOIN NOC_OCCUPATIONS n ON c.NOC_CODE = SUBSTRING(n.NOC_CODE, 1, 5)
WHERE cfv.ONET_SOC_CODE IN (
    '15-1252.00',  -- Software Developers
    '25-2031.00',  -- Teachers
    '11-3031.00',  -- Financial Managers
    '29-1141.00'   -- Nurses
)
ORDER BY cfv.ONET_SOC_CODE;
```

**Expected Result:**
- 4 rows returned
- All have `canadian_title` populated
- `MAPPING_CONFIDENCE` = 'HIGH' or 'MEDIUM'

---

## Troubleshooting

### Issue: "File not found in stage"
**Solution:** Re-upload the specific CSV file to `@NOC_STAGE`

### Issue: "Column count mismatch"
**Solution:** Check CSV has correct headers; use `ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE` in script

### Issue: "0 rows loaded"
**Solution:**
1. Verify files uploaded: `LIST @NOC_STAGE;`
2. Check file names match exactly (case-sensitive)
3. Re-run COPY INTO command

### Issue: "Crosswalk/occupation not found"
**Solution:**
- This is normal for ~5-15% of careers (no NOC mapping)
- App will gracefully fall back to O*NET data

---

## Success Criteria

✅ **Phase 0.1 Complete When:**
- [ ] 11 CSV files uploaded to `@NOC_STAGE`
- [ ] `NOC_ONET_CROSSWALK` has 1,466 rows
- [ ] `NOC_OCCUPATIONS` has 900 rows
- [ ] Validation queries pass
- [ ] Test query shows Canadian enrichment working

**Estimated Snowflake Cost:** ~$0.50-1.00 for import (one-time)

---

## Next Steps

Once Phase 0.1 is complete, notify the development team:
- ✅ Snowflake NOC data deployed
- 🔄 Ready for Phase 0.2 (Swift code changes)

The iOS app changes (country selection UI, testing framework) will be implemented concurrently while you complete this Snowflake work.

---

**Questions?** Check `NOC_UPLOAD_FILES_GUIDE.md` for detailed troubleshooting.
