# HFSPL App

A comprehensive Flutter-based mobile application for loan management, from KYC (Know Your Customer) sourcing to collection. The application supports multiple loan types including MFI (Microfinance), NMFI (Non-Microfinance Individual), Personal Loans, and Loan Against Property (LAP).

## Overview

HFSPL App is an end-to-end loan processing system designed for field agents and loan officers to:
- Collect and verify customer KYC information
- Process loan applications for various loan types
- Conduct Due Diligence Evaluations (DDE)
- Perform verification sessions
- Monitor collections and overdues
- Track loan disbursements and repayments

## Features

### Loan Types Supported
- **MFI (Microfinance)** - Group-based microfinance loans
- **NMFI (Non-Microfinance Individual)** - Individual loan processing
  - Personal Loans
  - Loan Against Property (LAP)
- **Gold Loans** - Jewelry-backed loans
- **Other Loans** - Flexible loan type management

### Core Functionality
- 📋 **KYC Collection** - Digital KYC forms with Aadhaar verification
- 📸 **Document Management** - Image capture, compression, and PDF generation
- 📍 **Location Services** - GPS-based verification and center visits
- 🔍 **OCR Support** - Optical Character Recognition for document scanning
- 📊 **Dashboard Analytics** - Real-time loan status and collection monitoring
- 🗓️ **Center Visits** - Schedule and track field visits
- 💰 **Collection Management** - Track payments and overdues
- ✅ **Verification** - Multi-level verification workflow
- 🔔 **Notifications** - Push notifications via Firebase Cloud Messaging
- 📱 **Offline Support** - Works with intermittent connectivity

## Getting Started

### Prerequisites
- Flutter SDK (>=3.2.3 <4.0.0)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd HFSPL-App
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Firebase Setup
The app uses Firebase for notifications and cloud storage. Ensure you have:
- `google-services.json` (Android) in `android/app/`
- `GoogleService-Info.plist` (iOS) in `ios/Runner/`
- Firebase project configured in `firebase.json`

## Project Structure

```
lib/
├── models/              # Data models and entities
│   └── loan_type.dart   # Loan type enumerations
├── network/             # API clients and network calls
│   ├── networkcalls.dart
│   └── requests/        # Request models
├── state/               # State management
│   └── kyc_state.dart   # KYC and loan type state
├── apply_loan_views/    # KYC and loan application screens
├── Non MFI/             # NMFI-specific screens
├── Other_Loans/         # Other loan type screens
├── utils/               # Utility functions
└── main.dart            # App entry point
```

## Version History

### Version 1.0.2+242 (November 12, 2025)

#### 🆕 New Features
- **LAP (Loan Against Property) Support**
  - Added complete LAP loan processing workflow
  - Parameterized NMFI Dashboard to support multiple loan types
  - Implemented type-safe `LoanType` enum for better code maintainability
  - Zero code duplication approach using single dashboard for all NMFI loan types

#### ✨ Improvements
- **Enhanced State Management**
  - Centralized loan type management in `KycState`
  - Automatic loan type propagation to all API calls
  - Type-safe enum-based configuration (LoanType.personalLoan, LoanType.lap)

- **Backend Integration**
  - Added `loanType` parameter to 13+ API endpoints
  - KYC APIs: GetSnapshotList, CreateSnapshot, CategoryList, GetQuestions, etc.
  - DDE APIs: GetDDEEligibleMembers, GetAssignedDDEList, GetDDEDetailsById
  - Verification APIs: GetVerificationEligibleMembers, GetAssignedVerificationList

- **UI/UX Enhancements**
  - Dynamic dashboard titles based on loan type
  - Separate entry points for Personal Loan and LAP in Other Loans section
  - Consistent branding across loan types

#### 📝 Documentation
- Added comprehensive implementation guides:
  - `NMFI_LOAN_TYPE_IMPLEMENTATION.md` - Detailed technical documentation
  - `IMPLEMENTATION_SUMMARY.md` - High-level overview and success metrics
  - `QUICK_START_GUIDE.md` - Developer quick reference
  - `ARCHITECTURE_DIAGRAM.md` - System architecture documentation
  - `DEPLOYMENT_CHECKLIST.md` - Production deployment guidelines

#### 🔧 Technical Improvements
- **Scalable Architecture**
  - Easy to add new loan types (requires only ~20 lines of code)
  - Parameterized dashboard eliminates code duplication
  - Backward compatible with existing implementations

- **Code Quality**
  - No linter errors
  - Type-safe implementations
  - SOLID principles applied
  - DRY (Don't Repeat Yourself) principle maintained

### Previous Versions

#### Version 1.0.1 (November 1, 2025)
- **MFI Live Deployment** - Production release of MFI module
- **NMFI 1.0** - Initial release of Non-MFI individual loan processing
- Added DDE (Due Diligence Evaluation) verification workflows
- Enhanced file picker with document upload support
- Improved question pages with dynamic form generation

#### Version 1.0.0 (October 2025)
- Added OCR option for KYC document scanning
- Implemented collection and demand correction features
- Added center visit pages with location tracking
- Overdue tracking with last call details
- Fixed collection posting in BM (Branch Manager) module
- Added filters in OD (Overdue) monitoring
- Implemented individual mode singleton pattern
- Enhanced Aadhaar verification workflow

## Key Dependencies

- **Networking**: dio (^5.4.0)
- **State Management**: shared_preferences (^2.2.2)
- **UI Components**: flutter_spinkit, shimmer, dropdown_search
- **Location**: geolocator (^13.0.1), google_maps_flutter
- **Media**: image_picker, flutter_image_compress
- **Documents**: image_to_pdf_converter, file_picker
- **Firebase**: firebase_core, cloud_firestore, flutter_local_notifications
- **Utilities**: intl, url_launcher, connectivity_plus, crypto

## Architecture

### Design Patterns
- **Singleton Pattern** - State management (KycState)
- **Parameterization** - Reusable dashboard components
- **Enum Pattern** - Type-safe configurations
- **Repository Pattern** - Network layer abstraction

### State Management
- Centralized `KycState` for KYC and loan type management
- Singleton instance accessible throughout the app
- Automatic state propagation to API calls

### Backend Integration
- RESTful API communication via Dio
- Automatic retry mechanism for failed requests
- Request/response models with JSON serialization
- loanType parameter integration for data isolation

## Testing

Run tests using:
```bash
flutter test
```

## Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Configuration

### App Configuration
- **App Name**: HFSPL
- **Package**: Configure in `pubspec.yaml`
- **Version**: 1.0.2+242
- **Min SDK**: Configure in `android/app/build.gradle`

### Network Configuration
- Base URLs configured in `lib/network/networkcalls.dart`
- API endpoints follow RESTful conventions
- Authentication via session tokens

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

Private and confidential. All rights reserved.

## Support

For technical support or questions, contact the development team.

---

**Last Updated**: November 12, 2025  
**Current Version**: 1.0.2+242  
**Status**: ✅ Production Ready
