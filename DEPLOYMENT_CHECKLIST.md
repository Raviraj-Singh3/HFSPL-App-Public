# NMFI Loan Type - Deployment Checklist

## ✅ Pre-Deployment Checklist

### 📱 Frontend (Flutter App)

#### Code Review
- [x] All new files created successfully
  - [x] `lib/models/loan_type.dart`
  - [x] Updated `lib/state/kyc_state.dart`
  - [x] Updated `lib/Non MFI/nmfi_dashboard.dart`
  - [x] Updated `lib/network/networkcalls.dart`
  - [x] Updated `lib/Other_Loans/other_loan_dashboard.dart`
  - [x] Updated `lib/my_home_page.dart`

#### Linter Checks
- [x] No linter errors in new files
- [x] No linter errors in modified files (only pre-existing warnings)

#### Testing Required
- [ ] Test Personal Loan flow end-to-end
  - [ ] Open dashboard
  - [ ] Create snapshot
  - [ ] Fill KYC
  - [ ] Complete snapshot
  - [ ] Verify loanType=1 sent to backend
  
- [ ] Test LAP flow end-to-end
  - [ ] Open dashboard
  - [ ] Create snapshot
  - [ ] Fill KYC
  - [ ] Complete snapshot
  - [ ] Verify loanType=2 sent to backend

- [ ] Test DDE flow
  - [ ] Personal Loan DDE
  - [ ] LAP DDE
  - [ ] Verify data isolation

- [ ] Test Verification flow
  - [ ] Personal Loan Verification
  - [ ] LAP Verification
  - [ ] Verify data isolation

#### Build Tests
- [ ] Debug build successful
- [ ] Release build successful
- [ ] No compile errors
- [ ] No runtime errors

---

### 🖥️ Backend (API)

#### API Updates Required
The following API endpoints MUST be updated to accept and handle `loanType` parameter:

##### KYC APIs
- [ ] `GET /api/ClientApp/IndividualKyc/GetSnapshotList`
  - [ ] Accept `loanType` parameter
  - [ ] Filter by `loanType`
  
- [ ] `POST /api/ClientApp/IndividualKyc/CreateSnapshot`
  - [ ] Accept `loanType` parameter
  - [ ] Store `loanType` in database
  
- [ ] `POST /api/ClientApp/IndividualKyc/CategoryList`
  - [ ] Accept `loanType` parameter
  - [ ] Return appropriate categories for loan type
  
- [ ] `POST /api/ClientApp/IndividualKyc/GetQuestions`
  - [ ] Accept `loanType` parameter
  - [ ] Return loan-type specific questions
  
- [ ] `POST /api/ClientApp/IndividualKyc/CompleteSnapshot`
  - [ ] Accept `loanType` parameter
  - [ ] Validate based on loan type
  
- [ ] `POST /api/ClientApp/IndividualKyc/getKycStatus`
  - [ ] Accept `loanType` parameter
  - [ ] Filter status by loan type

##### DDE APIs
- [ ] `POST /api/ClientApp/IndividualDDE/GetDDEEligibleMembers`
  - [ ] Accept `loanType` parameter
  - [ ] Filter eligible members by loan type
  
- [ ] `POST /api/ClientApp/IndividualDDE/GetAssignedDDEList`
  - [ ] Accept `loanType` parameter
  - [ ] Filter assigned DDE by loan type
  
- [ ] `POST /api/ClientApp/IndividualDDE/GetDDEDetailsById`
  - [ ] Accept `loanType` parameter
  - [ ] Return details with loan type context

##### Verification APIs
- [ ] `POST /api/ClientApp/IndividualDDE/GetVerificationEligibleMembers`
  - [ ] Accept `loanType` parameter
  - [ ] Filter eligible members by loan type
  
- [ ] `POST /api/ClientApp/IndividualDDE/GetAssignedVerificationList`
  - [ ] Accept `loanType` parameter
  - [ ] Filter assigned verification by loan type
  
- [ ] `POST /api/ClientApp/IndividualDDE/GetVerificationDetailsById`
  - [ ] Accept `loanType` parameter
  - [ ] Return details with loan type context

#### Database Updates
- [ ] Add `LoanType` column to relevant tables
  ```sql
  -- Snapshots table
  ALTER TABLE Snapshots ADD LoanType INT NOT NULL DEFAULT 1;
  
  -- DDE Schedule table
  ALTER TABLE DDESchedule ADD LoanType INT NOT NULL DEFAULT 1;
  
  -- Verification Schedule table  
  ALTER TABLE VerificationSchedule ADD LoanType INT NOT NULL DEFAULT 1;
  
  -- Add indexes for performance
  CREATE INDEX IX_Snapshots_LoanType ON Snapshots(LoanType);
  CREATE INDEX IX_DDESchedule_LoanType ON DDESchedule(LoanType);
  CREATE INDEX IX_VerificationSchedule_LoanType ON VerificationSchedule(LoanType);
  ```

- [ ] Update existing data
  ```sql
  -- Set default loan type for existing records
  UPDATE Snapshots SET LoanType = 1 WHERE LoanType IS NULL OR LoanType = 0;
  UPDATE DDESchedule SET LoanType = 1 WHERE LoanType IS NULL OR LoanType = 0;
  UPDATE VerificationSchedule SET LoanType = 1 WHERE LoanType IS NULL OR LoanType = 0;
  ```

#### Controller Updates
- [ ] Update IndividualKycController
  - [ ] Add loanType parameter to all relevant actions
  - [ ] Add WHERE clause filtering by loanType
  - [ ] Update validation logic for loan-specific rules
  
- [ ] Update IndividualDDEController
  - [ ] Add loanType parameter to all relevant actions
  - [ ] Filter queries by loanType
  - [ ] Update business logic for loan-specific processing

#### API Testing
- [ ] Test all endpoints with loanType=1 (Personal)
- [ ] Test all endpoints with loanType=2 (LAP)
- [ ] Test data isolation between loan types
- [ ] Test backward compatibility (existing clients)
- [ ] Test error handling for invalid loanType

---

### 📊 Data Migration

#### If You Have Existing Data
- [ ] Backup database before migration
- [ ] Run migration scripts to add LoanType column
- [ ] Set default loanType=1 for all existing records
- [ ] Verify data integrity after migration
- [ ] Test that existing functionality still works

#### Migration Script Template
```sql
-- Backup tables
SELECT * INTO Snapshots_Backup FROM Snapshots;
SELECT * INTO DDESchedule_Backup FROM DDESchedule;

-- Add columns
ALTER TABLE Snapshots ADD LoanType INT;
ALTER TABLE DDESchedule ADD LoanType INT;
ALTER TABLE VerificationSchedule ADD LoanType INT;

-- Set defaults
UPDATE Snapshots SET LoanType = 1;
UPDATE DDESchedule SET LoanType = 1;
UPDATE VerificationSchedule SET LoanType = 1;

-- Make NOT NULL after setting defaults
ALTER TABLE Snapshots ALTER COLUMN LoanType INT NOT NULL;
ALTER TABLE DDESchedule ALTER COLUMN LoanType INT NOT NULL;
ALTER TABLE VerificationSchedule ALTER COLUMN LoanType INT NOT NULL;

-- Add indexes
CREATE INDEX IX_Snapshots_LoanType ON Snapshots(LoanType);
CREATE INDEX IX_DDESchedule_LoanType ON DDESchedule(LoanType);
CREATE INDEX IX_VerificationSchedule_LoanType ON VerificationSchedule(LoanType);

-- Verify
SELECT LoanType, COUNT(*) FROM Snapshots GROUP BY LoanType;
SELECT LoanType, COUNT(*) FROM DDESchedule GROUP BY LoanType;
```

---

### 🧪 Testing Scenarios

#### Scenario 1: New Personal Loan
1. [ ] Open "NMFI - Personal Loan" from Other Loans
2. [ ] Dashboard shows "Personal Loan" branding
3. [ ] Create new snapshot
4. [ ] Verify API call includes `loanType=1`
5. [ ] Fill KYC forms
6. [ ] Complete snapshot
7. [ ] Verify database has `LoanType=1`

#### Scenario 2: New LAP
1. [ ] Open "NMFI - LAP" from Other Loans
2. [ ] Dashboard shows "Loan Against Property" branding
3. [ ] Create new snapshot
4. [ ] Verify API call includes `loanType=2`
5. [ ] Fill KYC forms (should be LAP-specific if different)
6. [ ] Complete snapshot
7. [ ] Verify database has `LoanType=2`

#### Scenario 3: Data Isolation
1. [ ] Create Personal Loan snapshot
2. [ ] Create LAP snapshot
3. [ ] Open Personal Loan dashboard
4. [ ] Verify ONLY Personal Loan snapshots visible
5. [ ] Open LAP dashboard
6. [ ] Verify ONLY LAP snapshots visible

#### Scenario 4: DDE Flow
1. [ ] Complete KYC for Personal Loan
2. [ ] Complete KYC for LAP
3. [ ] Check DDE eligible list for Personal
4. [ ] Check DDE eligible list for LAP
5. [ ] Verify lists are separated by loan type

#### Scenario 5: Backward Compatibility
1. [ ] Existing Personal Loan data still accessible
2. [ ] No errors for old records
3. [ ] Old functionality still works

---

### 📝 Documentation

#### Documentation Files Created
- [x] `NMFI_LOAN_TYPE_IMPLEMENTATION.md` - Detailed technical guide
- [x] `QUICK_START_GUIDE.md` - Developer quick reference
- [x] `IMPLEMENTATION_SUMMARY.md` - Executive summary
- [x] `ARCHITECTURE_DIAGRAM.md` - Visual architecture guide
- [x] `DEPLOYMENT_CHECKLIST.md` - This file

#### Documentation Review
- [ ] All documentation reviewed for accuracy
- [ ] Code examples tested
- [ ] SQL scripts verified
- [ ] Diagrams accurate

---

### 🚀 Deployment Steps

#### Stage 1: Backend Deployment
1. [ ] Deploy database changes
   - [ ] Run migration scripts in test environment
   - [ ] Verify migrations successful
   - [ ] Test API with new schema
   - [ ] Deploy to production database

2. [ ] Deploy API changes
   - [ ] Update API code to handle loanType
   - [ ] Deploy to test environment
   - [ ] Run integration tests
   - [ ] Deploy to production

3. [ ] Verify backend
   - [ ] Test all endpoints with Postman/Swagger
   - [ ] Verify loanType parameter working
   - [ ] Check logs for errors

#### Stage 2: Frontend Deployment
1. [ ] Build Flutter app
   - [ ] Run `flutter clean`
   - [ ] Run `flutter pub get`
   - [ ] Run `flutter build apk --release` (Android)
   - [ ] Run `flutter build ios --release` (iOS)

2. [ ] Test release build
   - [ ] Install on test device
   - [ ] Test all scenarios
   - [ ] Check for crashes

3. [ ] Deploy to stores
   - [ ] Upload to Google Play Console
   - [ ] Upload to App Store Connect
   - [ ] Update release notes mentioning LAP support

---

### 🔍 Post-Deployment Verification

#### Immediate Checks (Day 1)
- [ ] Monitor error logs
- [ ] Check API call success rates
- [ ] Verify no crashes reported
- [ ] Test production with real users

#### Week 1 Monitoring
- [ ] Track Personal Loan usage
- [ ] Track LAP usage
- [ ] Monitor database performance
- [ ] Check for any unexpected issues

#### Metrics to Track
- [ ] Number of Personal Loan snapshots created
- [ ] Number of LAP snapshots created
- [ ] API response times for loanType queries
- [ ] User feedback on LAP feature

---

### 🐛 Rollback Plan

If Issues Occur:

#### Frontend Rollback
1. [ ] Revert to previous app version in stores
2. [ ] Notify users of temporary issue
3. [ ] Deploy hotfix if possible

#### Backend Rollback
1. [ ] Revert API changes
2. [ ] Keep database schema (backward compatible)
3. [ ] Set all loanType to 1 temporarily if needed

#### Emergency Fixes
- [ ] Backend makes loanType parameter optional (default to 1)
- [ ] Frontend can still work with old API
- [ ] No data loss

---

### ✅ Sign-Off

#### Development Team
- [ ] Code review completed
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Ready for QA

#### QA Team
- [ ] All test scenarios passed
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Ready for staging

#### Product Owner
- [ ] Feature meets requirements
- [ ] Approved for production
- [ ] Release notes approved

#### DevOps
- [ ] Backend deployed successfully
- [ ] Frontend deployed successfully
- [ ] Monitoring in place
- [ ] Rollback plan ready

---

### 📞 Support Information

**If Issues Arise:**

1. Check logs:
   - Backend API logs for errors
   - Flutter app logs (flutter logs)
   - Database query logs

2. Common Issues:
   - Missing loanType parameter → Check KycState is set
   - Wrong data showing → Check API filtering by loanType
   - Backward compatibility → Ensure default loanType=1

3. Contact:
   - Development Team: [Your contact]
   - DevOps: [Your contact]
   - On-call: [Your contact]

---

## 🎉 Launch Checklist

### Day of Launch
- [ ] All deployment steps completed
- [ ] All verifications passed
- [ ] Team on standby
- [ ] Monitoring active
- [ ] Rollback plan ready

### Communication
- [ ] Announce LAP feature to users
- [ ] Update help documentation
- [ ] Train support team
- [ ] Prepare FAQ

---

**Remember**: This is a major feature addition. Take time to test thoroughly! 🚀

**Good luck with your deployment!** 💪

