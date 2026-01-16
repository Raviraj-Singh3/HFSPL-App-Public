# Quick Start Guide - NMFI Loan Types

## 🚀 For Developers

### Using the NMFI Dashboard

#### Opening Dashboard with Loan Type
```dart
// Personal Loan (default)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NMFIDashboard(),
  ),
);

// LAP (Loan Against Property)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NMFIDashboard(loanType: LoanType.lap),
  ),
);
```

#### Setting Loan Type in KycState
```dart
// Option 1: Set during individual mode
KycState().setIndividualMode(loanType: LoanType.lap);

// Option 2: Set separately
KycState().setLoanType(LoanType.lap);

// Option 3: Set by ID (from backend)
KycState().setLoanTypeById(2); // 2 = LAP
```

#### Getting Current Loan Type
```dart
// Get enum
LoanType currentType = KycState().loanType;

// Get ID for API
int typeId = KycState().loanTypeId;

// Get display name
String displayName = KycState().loanType.title;
```

---

## 📝 Adding New Loan Type

### Step 1: Add to Enum (5 minutes)
**File**: `lib/models/loan_type.dart`

```dart
enum LoanType {
  personalLoan(1, 'Personal Loan', '...', '...'),
  lap(2, 'Loan Against Property', '...', '...'),
  // NEW: Add your loan type here
  businessLoan(3, 'Business Loan', 'SME Financing', 'Complete description...'),
}
```

### Step 2: Add Entry Point (5 minutes)
**File**: `lib/Other_Loans/other_loan_dashboard.dart`

Find the existing loan cards and add:
```dart
_buildLoanCard(
  title: 'NMFI - Business Loan',
  description: 'SME business financing with complete workflow',
  icon: Icons.business,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NMFIDashboard(loanType: LoanType.businessLoan)
      ),
    );
  },
),
```

### Step 3: Update Backend (Variable time)
- Add `loanType=3` support in your API controllers
- Update database schema if needed
- Test API endpoints

**That's it!** The rest works automatically. ✨

---

## 🔍 Common Patterns

### Pattern 1: Conditional Logic Based on Loan Type
```dart
void someFunction() {
  final loanType = KycState().loanType;
  
  switch (loanType) {
    case LoanType.personalLoan:
      // Personal loan specific logic
      break;
    case LoanType.lap:
      // LAP specific logic
      break;
  }
}
```

### Pattern 2: Display Loan Type Info
```dart
Text('Current Loan: ${KycState().loanType.title}')
```

### Pattern 3: API Calls Automatically Include Loan Type
```dart
// No need to pass loanType manually!
// It's automatically picked from KycState
await _client.loadIndivisualSnapshot();
// API: .../GetSnapshotList?UserId=123&loanType=2
```

---

## 🐛 Debugging

### Check Current Loan Type
```dart
print(KycState().toString());
// Output: KycState(isIndividual: true, loanType: Loan Against Property (2))
```

### Verify API Calls
Use network inspector to check if `loanType` parameter is being sent:
```
GET .../GetSnapshotList?UserId=123&loanType=2
                                        ↑
                                  Should be present
```

### Reset Loan Type
```dart
KycState().setLoanType(LoanType.personalLoan);
```

---

## 📋 Files Modified

| File | Purpose |
|------|---------|
| `lib/models/loan_type.dart` | Loan type enum definition |
| `lib/state/kyc_state.dart` | State management with loan type |
| `lib/Non MFI/nmfi_dashboard.dart` | Parameterized dashboard |
| `lib/network/networkcalls.dart` | API calls with loan type |
| `lib/Other_Loans/other_loan_dashboard.dart` | Entry points for loan types |
| `lib/my_home_page.dart` | Main navigation |

---

## 🎯 Key Concepts

1. **Single Dashboard**: One `NMFIDashboard` serves all loan types
2. **Enum Configuration**: Type-safe loan type definitions
3. **State Management**: `KycState` tracks current loan type
4. **Automatic Propagation**: Loan type flows through all APIs
5. **No Duplication**: Zero code duplication between loan types

---

## 💡 Tips

- Always set loan type before navigating to KYC
- Use enum values, not hardcoded numbers
- Let the system handle API parameters automatically
- Add new loan types by just updating the enum
- Backend should filter by `loanType` parameter

---

## ❓ FAQ

**Q: Do I need to pass loanType to API calls manually?**  
A: No! It's automatically picked from `KycState().loanTypeId`

**Q: Can I have different KYC questions for different loan types?**  
A: Yes! Backend should return different questions based on loanType parameter

**Q: How do I test LAP flow without affecting Personal loans?**  
A: Just use `NMFIDashboard(loanType: LoanType.lap)`. Data is isolated by loanType

**Q: What if I need loan-specific logic in the dashboard?**  
A: Use `widget.loanType` to access current type and add conditional logic

---

## 📞 Need Help?

Check the detailed documentation: `NMFI_LOAN_TYPE_IMPLEMENTATION.md`

