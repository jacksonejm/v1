# NOC Data Import: CSV Upload Guide

## Current Issue
✅ **Tables created successfully:**
- `NOC_ONET_CROSSWALK` (empty - 0 rows)
- `NOC_OCCUPATIONS` (empty - 0 rows)

❌ **Problem:** CSV files not uploaded to Snowflake stage before running COPY INTO commands

## Solution: Upload CSV Files to Snowflake

You need to upload **11 CSV files** to the `NOC_STAGE` in Snowflake:

### Option A: Using Snowsight Web UI (Recommended)

1. **Open Snowsight** and navigate to:
   ```
   Data > Databases > ONET_CAREER_DB > CAREER_SCHEMA > Stages > NOC_STAGE
   ```

2. **Click "Upload Files"** button

3. **Select these 11 files** from your local machine:

   **From `/Users/eddym/Downloads/app/carrer/NOC/Cross/`:**
   - `noc2021_onet26.csv` (Crosswalk - 1,466 mappings)

   **From `/Users/eddym/Downloads/app/carrer/NOC/`:**
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

4. **Click "Upload"** and wait for completion

5. **Verify upload:**
   ```sql
   LIST @NOC_STAGE;
   ```
   Expected: 11 files listed

### Option B: Using SnowSQL Command Line

If you have SnowSQL installed:

```bash
cd /Users/eddym/Downloads/app/carrer

# Upload crosswalk
PUT file:///Users/eddym/Downloads/app/carrer/NOC/Cross/noc2021_onet26.csv @NOC_STAGE AUTO_COMPRESS=FALSE;

# Upload OaSIS files
PUT file:///Users/eddym/Downloads/app/carrer/NOC/0131ca04-0379-4c1f-b814-05fb139b9718.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/7941081c-a0ce-4add-aa2c-74aa96b1c57f.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/8cc1bd89-afa1-4cfe-b45a-d6511d9318d7.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/381efe24-1b50-4a18-b6bb-cb7d0fa0921f.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/053f7e1c-e629-432e-a70f-ed043e028f65.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/e080bd8a-a760-488d-81f8-e6e6f50c6396.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/66414d34-029e-4d0e-b6e5-ae3d99a73fac.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/e3599639-3540-4d39-a42b-f7d41909d6d4.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/79361933-2793-4e1e-b255-b6fa214ef28d.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
PUT file:///Users/eddym/Downloads/app/carrer/NOC/0553ee55-1a87-4709-bd61-3739af0322a3.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
```

## After Upload: Re-run Import Scripts

Once files are uploaded, you need to **re-load the data** (tables already exist, just empty):

### Step 1: Load Crosswalk Data

Run **Section 5-7 only** from `NOC_STEP1_IMPORT_CROSSWALK.sql`:

```sql
-- SECTION 5: Load Data from CSV (lines 123-141)
COPY INTO CROSSWALK_STAGING
FROM @NOC_STAGE/noc2021_onet26.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = CONTINUE;

SELECT 'Rows loaded into staging:' AS status, COUNT(*) AS row_count
FROM CROSSWALK_STAGING;

-- SECTION 7: Insert into Production Table (lines 197-227)
INSERT INTO NOC_ONET_CROSSWALK (
    NOC_CODE,
    NOC_TITLE,
    ONET_CODE,
    ONET_TITLE,
    MAPPING_SOURCE,
    MAPPING_CONFIDENCE
)
SELECT
    TRIM(noc) AS NOC_CODE,
    TRIM(noc_title) AS NOC_TITLE,
    TRIM(onet) AS ONET_CODE,
    TRIM(onet_title) AS ONET_TITLE,
    'BROOKFIELD_2021' AS MAPPING_SOURCE,
    CASE
        WHEN (SELECT COUNT(*) FROM CROSSWALK_STAGING s2 WHERE s2.noc = s1.noc) = 1
        THEN 'HIGH'
        WHEN (SELECT COUNT(*) FROM CROSSWALK_STAGING s2 WHERE s2.noc = s1.noc) <= 3
        THEN 'MEDIUM'
        ELSE 'LOW'
    END AS MAPPING_CONFIDENCE
FROM CROSSWALK_STAGING s1
WHERE TRIM(noc) IS NOT NULL AND TRIM(onet) IS NOT NULL;

SELECT COUNT(*) FROM NOC_ONET_CROSSWALK;
-- Expected: 1,466 rows
```

### Step 2: Load OaSIS Data

Run **Sections 3-7 only** from `NOC_STEP2_IMPORT_OASIS_DISPLAY.sql` (lines 69-580).

Or easier: Just re-run the entire `NOC_STEP2_IMPORT_OASIS_DISPLAY.sql` script - it uses `CREATE OR REPLACE` so it's safe.

### Step 3: Validate

Run `NOC_STEP3_VALIDATION_QUERIES.sql` to verify:
- Expected: 1,466 crosswalk mappings
- Expected: 900 NOC occupations
- Expected: ~94% O*NET to NOC coverage

## Quick Verification After Upload

```sql
-- Check files are uploaded
LIST @NOC_STAGE;

-- Should show 11 files
```

## Summary

**Current Status:**
- ✅ SQL scripts are syntax-error-free
- ✅ Tables created successfully
- ❌ CSV files not uploaded to Snowflake stage
- ❌ Data not imported (0 rows)

**Next Action:**
1. Upload 11 CSV files to Snowflake stage (see Option A or B above)
2. Re-run data import sections (COPY INTO + INSERT commands)
3. Run validation queries

The column name errors (`TITLE` → `JOB_TITLE`) have been fixed in NOC_STEP3_VALIDATION_QUERIES.sql.
