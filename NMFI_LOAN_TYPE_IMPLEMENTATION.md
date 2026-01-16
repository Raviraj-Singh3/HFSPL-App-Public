# NMFI Loan Type Implementation - Hybrid Solution

## Overview
This document describes the hybrid solution implemented for supporting multiple loan types (Personal Loan, LAP, etc.) in the NMFI system without code duplication.

## Architecture Design

### ✅ Solution: Parameterized Dashboard + Enum Configuration

Instead of copying the NMFI Dashboard for each loan type, we implemented a **parameterized dashboard** that accepts a `LoanType` parameter, combined with a **type-safe enum** for loan configuration.

### Key Benefits
- ✅ **No Code Duplication**: Single `NMFIDashboard` serves all loan types
- ✅ **Easy to Extend**: Add new loan types by just adding enum values
- ✅ **Type Safety**: Compile-time checks with enums
- ✅ **Centralized State**: `KycState` manages both mode and loan type
- ✅ **Backend Integration**: `loanType` parameter flows through all APIs

---

## Implementation Components

### 1. LoanType Enum (`lib/models/loan_type.dart`)

```dart
enum LoanType {
  personalLoan(1, 'Personal Loan', 'Individual Personal Loan Processing', ...),
  lap(2, 'Loan Against Property', 'Property-backed Loan Processing', ...);
  
  final int id;          // Database/API identifier
  final String title;    // Display name
  final String subtitle; // Short description
  final String description; // Detailed description
}
```

**Features:**
- Each loan type has a unique ID (1 = Personal, 2 = LAP)
- Provides consistent labeling across the app
- Helper methods like `dashboardTitle`, `kycLabel`, etc.
- Static `fromId()` method for reverse lookup

**To Add New Loan Type:**
```dart
enum LoanType {
  personalLoan(1, ...),
  lap(2, ...),
  businessLoan(3, 'Business Loan', 'SME Business Financing', 'Details...'), // NEW
}
```

---

### 2. Enhanced KycState (`lib/state/kyc_state.dart`)

**New Properties:**
```dart
LoanType _loanType = LoanType.personalLoan;  // Current loan type
int get loanTypeId => _loanType.id;          // ID for API calls
```

**New Methods:**
```dart
// Set individual mode with optional loan type
setIndividualMode({LoanType? loanType})

// Set loan type explicitly
setLoanType(LoanType loanType)
setLoanTypeById(int loanTypeId)

// Enhanced setKycMode
setKycMode(bool isIndividual, {LoanType? loanType})
```

**Usage Pattern:**
```dart
// Before navigating to KYC
KycState().setIndividualMode(loanType: LoanType.lap);

// Or set separately
KycState().setIndividualMode();
KycState().setLoanType(LoanType.lap);
```

---

### 3. Parameterized NMFIDashboard (`lib/Non MFI/nmfi_dashboard.dart`)

**Constructor:**
```dart
class NMFIDashboard extends StatefulWidget {
  final LoanType loanType;
  
  const NMFIDashboard({
    Key? key, 
    this.loanType = LoanType.personalLoan, // Default
  }) : super(key: key);
}
```

**Dynamic Content:**
- App bar title: `widget.loanType.dashboardTitle`
- Header title: `widget.loanType.title`
- Header subtitle: `widget.loanType.subtitle`
- Information section includes loan type

**Navigation Example:**
```dart
// For Personal Loan
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NMFIDashboard(loanType: LoanType.personalLoan)
  ),
);

// For LAP
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NMFIDashboard(loanType: LoanType.lap)
  ),
);
```

---

### 4. Network Integration (`lib/network/networkcalls.dart`)

**Global Variables:**
```dart
final isIndividual = KycState().isIndividual;
final loanTypeId = KycState().loanTypeId;  // NEW
```

**Updated APIs:**
All Individual KYC, DDE, and Verification APIs now include `loanType` parameter:

```dart
// KYC APIs
GET /api/ClientApp/IndividualKyc/GetSnapshotList?UserId={uid}&loanType={loanTypeId}
POST /api/ClientApp/IndividualKyc/CreateSnapshot?...&loanType={loanTypeId}
POST /api/ClientApp/IndividualKyc/CategoryList?snapshotId={id}&loanType={loanTypeId}
POST /api/ClientApp/IndividualKyc/GetQuestions?...&loanType={loanTypeId}
POST /api/ClientApp/IndividualKyc/CompleteSnapshot?...&loanType={loanTypeId}
POST /api/ClientApp/IndividualKyc/getKycStatus?...&loanType={loanTypeId}

// DDE APIs
POST /api/ClientApp/IndividualDDE/GetDDEEligibleMembers?userId={id}&loanType={loanTypeId}
POST /api/ClientApp/IndividualDDE/GetAssignedDDEList?userId={id}&loanType={loanTypeId}
POST /api/ClientApp/IndividualDDE/GetDDEDetailsById?ddeScheduleId={id}&loanType={loanTypeId}

// Verification APIs
POST /api/ClientApp/IndividualDDE/GetVerificationEligibleMembers?userId={id}&loanType={loanTypeId}
POST /api/ClientApp/IndividualDDE/GetAssignedVerificationList?userId={id}&loanType={loanTypeId}
POST /api/ClientApp/IndividualDDE/GetVerificationDetailsById?ddeScheduleId={id}&loanType={loanTypeId}
```

---

### 5. Entry Points

#### Main Home Page (`lib/my_home_page.dart`)
```dart
_buildButton(
  context,
  icon: Icons.account_balance_wallet,
  label: "NMFI - Personal",
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const NMFIDashboard()),
  ),
),
```

#### Other Loans Dashboard (`lib/Other_Loans/other_loan_dashboard.dart`)
```dart
// Personal Loan Card
_buildLoanCard(
  title: 'NMFI - Personal Loan',
  description: 'Individual personal loan processing...',
  icon: Icons.person,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NMFIDashboard(loanType: LoanType.personalLoan)
    ),
  ),
),

// LAP Card
_buildLoanCard(
  title: 'NMFI - Loan Against Property',
  description: 'Property-backed loan processing...',
  icon: Icons.home_work,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NMFIDashboard(loanType: LoanType.lap)
    ),
  ),
),
```

---

## Data Flow

### 1. User Navigates to NMFI Dashboard
```
User clicks "NMFI - LAP" 
  → Navigator.push with NMFIDashboard(loanType: LoanType.lap)
  → Dashboard renders with LAP-specific labels
```

### 2. User Clicks "KYC Collection"
```
KYC button clicked
  → KycState().setIndividualMode(loanType: LoanType.lap)
  → Navigates to ListSnapshot
  → ListSnapshot loads snapshots via API
```

### 3. API Call with Loan Type
```
_client.loadIndivisualSnapshot()
  → Uses KycState().loanTypeId (returns 2 for LAP)
  → API: GET .../GetSnapshotList?UserId=123&loanType=2
  → Backend filters/processes based on loanType=2
```

### 4. Complete Workflow
```
Dashboard (LAP selected)
  ↓ (sets KycState)
KYC Collection
  ↓ (API with loanType=2)
Questions/Forms
  ↓ (API with loanType=2)
DDE Assignment
  ↓ (API with loanType=2)
Verification
  ↓ (API with loanType=2)
Complete
```

---

## Backend Requirements

### Database Schema Considerations
Ensure your backend tables include `LoanType` column:
```sql
-- Example for snapshots
ALTER TABLE Snapshots ADD LoanType INT DEFAULT 1;

-- Example for DDE
ALTER TABLE DDESchedule ADD LoanType INT DEFAULT 1;

-- Add indexes
CREATE INDEX IX_Snapshots_LoanType ON Snapshots(LoanType);
```

### API Controller Updates
Controllers should accept and filter by `loanType`:
```csharp
[HttpGet]
public async Task<IActionResult> GetSnapshotList(string userId, int loanType = 1)
{
    var snapshots = await _context.Snapshots
        .Where(s => s.UserId == userId && s.LoanType == loanType)
        .ToListAsync();
    
    return Ok(snapshots);
}
```

---

## Testing Checklist

### ✅ Personal Loan Flow (loanType = 1)
- [ ] Navigate to NMFI Dashboard (Personal)
- [ ] Create new snapshot
- [ ] Fill KYC forms
- [ ] Complete snapshot
- [ ] Verify loanType=1 in database
- [ ] Assign DDE
- [ ] Complete DDE
- [ ] Assign Verification
- [ ] Complete Verification

### ✅ LAP Flow (loanType = 2)
- [ ] Navigate to NMFI Dashboard (LAP)
- [ ] Create new snapshot
- [ ] Fill KYC forms (LAP-specific questions)
- [ ] Complete snapshot
- [ ] Verify loanType=2 in database
- [ ] Assign DDE
- [ ] Complete DDE
- [ ] Assign Verification
- [ ] Complete Verification

### ✅ Data Isolation
- [ ] Personal loan snapshots only show in Personal dashboard
- [ ] LAP snapshots only show in LAP dashboard
- [ ] DDE lists filtered by loan type
- [ ] Verification lists filtered by loan type

---

## Future Extensions

### Adding Loan Type 3 (e.g., Vehicle Loan)
1. **Update Enum** (`loan_type.dart`):
```dart
enum LoanType {
  personalLoan(1, ...),
  lap(2, ...),
  vehicleLoan(3, 'Vehicle Loan', 'Two/Four Wheeler Financing', 'Details...'),
}
```

2. **Add Entry Point** (`other_loan_dashboard.dart`):
```dart
_buildLoanCard(
  title: 'NMFI - Vehicle Loan',
  description: 'Two/Four wheeler financing',
  icon: Icons.directions_car,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NMFIDashboard(loanType: LoanType.vehicleLoan)
    ),
  ),
),
```

3. **Update Backend**: Add loanType=3 support in APIs

That's it! No need to duplicate dashboard or logic.

---

## Migration Guide (For Existing Data)

If you have existing data with implicit loanType=1:

```sql
-- Set default loan type for existing records
UPDATE Snapshots SET LoanType = 1 WHERE LoanType IS NULL;
UPDATE DDESchedule SET LoanType = 1 WHERE LoanType IS NULL;
UPDATE VerificationSchedule SET LoanType = 1 WHERE LoanType IS NULL;
```

---

## Troubleshooting

### Issue: APIs not receiving loanType parameter
**Solution**: Ensure KycState is set before navigation:
```dart
KycState().setIndividualMode(loanType: widget.loanType);
Navigator.push(...);
```

### Issue: Wrong snapshots showing in dashboard
**Solution**: Check backend filtering by loanType parameter

### Issue: LoanType enum not found
**Solution**: Ensure import:
```dart
import 'package:HFSPL/models/loan_type.dart';
```

---

## Summary

This hybrid solution provides:
- ✅ **Single Source of Truth**: One dashboard, multiple configurations
- ✅ **Type Safety**: Enum-based approach prevents errors
- ✅ **Maintainability**: Changes in one place apply to all loan types
- ✅ **Scalability**: Easy to add new loan types
- ✅ **Backend Integration**: loanType flows through entire system

**Result**: Clean, maintainable code without duplication! 🎉

