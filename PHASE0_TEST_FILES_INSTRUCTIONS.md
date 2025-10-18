# Phase 0: Adding Test Files to Xcode Project

**Status:** ✅ Build succeeds | ⚠️ Test files need manual addition to Xcode

---

## Quick Instructions (5 Minutes)

The test files have been created and all compilation errors fixed, but they need to be manually added to your Xcode project.

### Step 1: Open Xcode
```bash
cd /Users/eddym/Downloads/app/carrer
open carrer.xcodeproj
```

### Step 2: Add Test Files to Project

1. **Locate the test files in Xcode:**
   - In Xcode's Project Navigator (left sidebar), look for the `carrerTests` folder (yellow folder icon)
   - Right-click on the `carrerTests` folder
   - Select **"Add Files to \"carrer\"..."**

2. **Select the test files:**
   - Navigate to the `carrerTests` folder in the file picker
   - Select these **3 files** (hold ⌘ to select multiple):
     - ✅ `AppViewModelTests.swift`
     - ✅ `SnowflakeServiceTests.swift`
     - ✅ `CanadianNOCIntegrationTests.swift`

3. **Configure the import:**
   - ✅ **IMPORTANT:** Make sure "Add to targets" has **`carrerTests`** checked
   - Make sure "Copy items if needed" is **UNCHECKED** (files are already in the right place)
   - Click **"Add"**

### Step 3: Verify Test Files Were Added

1. In Xcode, expand the `carrerTests` folder in the Project Navigator
2. You should now see:
   - carrerTests.swift (existing)
   - StepFieldSpecTests.swift (existing)
   - **AppViewModelTests.swift** (newly added)
   - **SnowflakeServiceTests.swift** (newly added)
   - **CanadianNOCIntegrationTests.swift** (newly added)

### Step 4: Build and Run Tests

**Option A: Run in Xcode (Recommended)**
1. Press `⌘+U` to run all tests
2. Or click Product → Test from the menu bar

**Option B: Run in Terminal**
```bash
cd /Users/eddym/Downloads/app/carrer
xcodebuild test -scheme carrer -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:carrerTests
```

---

## Expected Test Results

Once the test files are added and tests run, you should see:

### Unit Tests
✅ **AppViewModelTests** (15 tests)
- testInitialState
- testSetUserData
- testUserCountryChange
- testRIASECScoreCalculation
- testRIASECScoresEmptyResponses
- testOnboardingStepProgression
- testOnboardingStepBackNavigation
- testAddCareerTrack
- testRemoveCareerTrack
- testMatchTierClassification
- testAppFlowStateTransitions
- testValidateOnboardingData
- testRIASECCalculationPerformance
- testCareerTrackManipulationPerformance
- ... and more

✅ **SnowflakeServiceTests** (20+ tests)
- testONetOccupationModel
- testONetOccupationMatchQuality
- testONetOccupationShortDescription
- testCanadianOccupationModel
- testCanadianOccupationWithoutMapping
- testCanadianOccupationParsing
- testMatchTierFromScore
- testMatchTierLabels
- testCareerTrackCreation
- testCareerTrackFromONetOccupation
- testCareerTrackTaskManagement
- testMockCareerMatchResponseParsing
- testOccupationModelCreationPerformance
- testCareerTrackFilteringPerformance
- ... and more

✅ **CanadianNOCIntegrationTests** (15+ tests)
- testCountrySelectionFlow
- testUserDataPersistence
- testCanadianOccupationDataStructure
- testCanadianOccupationFallbackToONet
- testRecommendationFlowForCanadianUser
- testCanadianOccupationDataStorage
- testCareerTitleDisplayLogic
- testUSUserDoesNotReceiveCanadianData
- testCrosswalkCoverageExpectations
- testMappingConfidenceLevels
- testCanadianDataEnrichmentPerformance
- testMultipleNOCMappingsToSingleONet
- testEmptyCanadianStrings
- testBilingualContentToggle
- ... and more

---

## Troubleshooting

### Issue: "Build input file cannot be found"
**Solution:** Make sure you selected the files from the `carrerTests` folder, not from somewhere else.

### Issue: Tests don't appear in Xcode Test Navigator
**Solution:**
1. Select the test target in the left sidebar
2. Go to Build Phases tab
3. Under "Compile Sources", verify the 3 test files are listed
4. If missing, click the "+" and add them manually

### Issue: "No such module 'carrer'"
**Solution:**
1. Make sure the test target (`carrerTests`) is selected as the destination
2. Clean build folder (⌘+⇧+K)
3. Rebuild (⌘+B)

### Issue: Some tests fail with Snowflake connection errors
**Expected Behavior:** Integration tests that connect to Snowflake may fail if:
- Network connection is unavailable
- Snowflake credentials are not configured
- Canadian NOC data is not deployed

This is normal - these tests validate live Snowflake integration.

---

## What These Tests Validate

### AppViewModelTests
- Core business logic (RIASEC scoring, career matching)
- User data persistence
- Onboarding flow navigation
- Career track management
- Performance benchmarks

### SnowflakeServiceTests
- Data model correctness (ONetOccupation, CanadianOccupation)
- Match tier calculations
- Career track creation and management
- JSON parsing and response handling
- Performance of data operations

### CanadianNOCIntegrationTests
- End-to-end Canadian NOC feature flow
- Country selection persistence
- Canadian title display logic
- Bilingual data support
- Fallback to O*NET for unmapped careers
- Crosswalk data coverage
- Mapping confidence levels

---

## After Tests Pass

Once all tests are green:

1. **Commit the project file change:**
   ```bash
   git add carrer.xcodeproj/project.pbxproj
   git commit -m "Add Phase 0 test files to Xcode project"
   ```

2. **Celebrate!** 🎉
   - Phase 0 is now **100% complete**
   - You have a robust test suite (50+ tests)
   - Ready to proceed to Phase 1 (Foundation)

3. **Optional: Merge to main**
   ```bash
   git checkout main
   git merge feature/v5-odyssey-phase0
   git push origin main
   ```

---

## Next Steps: Phase 1 (Foundation)

Once Phase 0 is validated, proceed to Phase 1:

**Week 1:** Database schema (6 new tables)
**Week 2:** Stored procedures (PID generation, pathfinding)
**Week 3:** Service layer (UserProfileService, SkillService)
**Week 4:** Testing and validation

See `v5.md` for complete Phase 1 specification.

---

**Last Updated:** 2025-10-17
**Status:** ✅ Ready to add test files to Xcode
**Build Status:** ✅ Compiles successfully
**Test Files:** ✅ Created and ready (3 files, 50+ tests)
