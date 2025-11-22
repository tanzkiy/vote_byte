# Vote BYTE – Digital Voting System

Vote BYTE is a cross-platform **Flutter** application that enables secure, transparent, and user-friendly elections for student organizations, clubs, and small communities.  It empowers voters to cast ballots from any device (mobile, desktop, or web) while giving administrators real-time visibility into results and complete control over the election lifecycle.

---

## Table of Contents

1. [Features](#features)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Getting Started](#getting-started)
5. [Running & Building](#running--building)
6. [Testing & Linting](#testing--linting)
7. [User Manual](#user-manual)
   * [Voter Guide](#voter-guide)
   * [Administrator Guide](#administrator-guide)
8. [Data Model & Storage](#data-model--storage)
9. [Security & Privacy](#security--privacy)
10. [Contributing](#contributing)
11. [License](#license)

---

## Features

⚡ **Fast Cross-Platform Experience**  
Runs natively on **Android, iOS, Web, Windows, macOS, and Linux** via Flutterʼs single code-base.

🔐 **Secure Authentication**  
• Firebase Email/Password sign-in.  
• Local fallback authentication if Firebase is unavailable (useful for offline demos).

🗳️ **End-to-End Voting Workflow**  
• Browse candidate profiles with images & descriptions.  
• Vote for multiple positions (President, Vice-President, Secretary, etc.).  
• Ballots are stored in Firestore; on the web-only fallback, votes are persisted to in-memory/SharedPreferences.

📊 **Live Results Dashboard**  
• Administrators can view dynamic vote counts and analytics in real time.  
• Voting can be enabled/paused at any time.

🌐 **Offline / Web Fallback Mode**  
If Firebase is unreachable (e.g., during local demos or no Internet), the app seamlessly switches to an in-memory SQLite-like store powered by **sqflite_common_ffi_web** and SharedPreferences.

🎨 **Modern UI & Accessibility**  
• Google Fonts, Material 3 theming, Lottie animations.  
• Color-blind-safe palette, large tappable targets, screen-reader friendly labels.

🌱 **Sustainable & Inclusive Design**  
Highlights contributions to UN SDGs (Quality Education, Gender Equality, Reduced Inequalities, etc.) within dedicated advocacy screens.

---

## Technology Stack

| Layer | Tech / Library | Purpose |
|-------|---------------|---------|
| **Frontend** | [Flutter](https://flutter.dev) 3.x, Dart 3.9 | Cross-platform UI |
| **Auth** | [firebase_auth](https://pub.dev/packages/firebase_auth) | Email / password authentication |
| **Database** | [cloud_firestore](https://pub.dev/packages/cloud_firestore) | Remote vote & user storage |
|  | [sqflite](https://pub.dev/packages/sqflite) / [sqflite_common_ffi_web](https://pub.dev/packages/sqflite_common_ffi_web) | Local & Web fallback DB |
| **State / Logic** | Provider-style service layer (see `lib/services`) | Encapsulate auth, voting, and DB helpers |
| **Assets** | Google Fonts, Lottie animations, PNG images | Rich UI/UX |

---

## Project Structure

```
lib/
  ├── main.dart              # App bootstrap & theme
  ├── login_page.dart        # User authentication UI
  ├── vote_homepage.dart     # Post-login landing page for voters
  ├── admin_screen.dart      # Admin dashboard & election controls
  ├── voting_screen.dart     # Ballot casting UI
  ├── results_screen.dart    # Public results view
  ├── candidate_screen.dart  # Candidate profile & info
  ├── sdg_advocacy_screen.dart # SDG & GAD informational pages
  └── services/
        ├── auth_service.dart      # Login / register / session helpers
        ├── database_helper.dart   # SQLite + web fallback adapter
        └── voting_service.dart    # Business logic & Firestore integration
assets/
  └── images/                # Candidate photos, UI graphics
firebase_options.dart        # Auto-generated config (excluded from VCS)
```

---

## Getting Started

### Prerequisites

1. **Flutter SDK 3.19+** – [Install Guide](https://docs.flutter.dev/get-started/install).  
2. **Dart 3.9+** (bundled with Flutter).  
3. **Firebase Project** – Create a project in the [Firebase Console](https://console.firebase.google.com/):
   * Enable **Email/Password** authentication.  
   * Add **Cloud Firestore** & **Authentication** to your project.
4. **FlutterFire CLI** (optional) for generating `firebase_options.dart`:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### Installation

```bash
# 1. Clone
$ git clone https://github.com/your-org/vote_byte.git
$ cd vote_byte

# 2. Install dependencies
$ flutter pub get

# 3. (Optional) Configure Firebase if you created a new project
$ flutterfire configure
```

---

## Running & Building

| Target | Command |
|--------|---------|
| Android | `flutter run -d android` |
| iOS     | `flutter run -d ios` (macOS only) |
| Web     | `flutter run -d chrome` |
| Windows | `flutter run -d windows` |
| macOS   | `flutter run -d macos` |
| Linux   | `flutter run -d linux` |

Production builds:

```bash
# Android (APK / AAB)
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web static site
flutter build web --release

# Windows / macOS / Linux desktop
flutter build windows --release
```

---

## Testing & Linting

```bash
# Run unit/widget tests
flutter test

# Static analysis
flutter analyze
```

---

## User Manual

### Voter Guide

1. **Account Registration**  
   • Open the app and tap **Sign Up**.  
   • Provide your name, school e-mail, and a strong password.  
   • Verify your e-mail if required.

2. **Logging In**  
   • Enter your registered e-mail and password on the login screen.  
   • Forgotten your password? Use the "Forgot Password" link to reset via e-mail.

3. **Home Dashboard**  
   After login, youʼll land on the **Home** screen. From here you can:
   • View current elections and announcements.  
   • Access the **Vote Now** button when voting is enabled.  
   • Review Sustainable Development Goals (SDG) advocacy info.

4. **Viewing Candidates**  
   • Tap an election card or the **Vote Now** button.  
   • Browse each positionʼs candidates; tap a candidate to view their full profile and platform.

5. **Casting Your Vote**  
   • For every position (President, Vice-President, Secretary, etc.), select exactly one candidate or choose **Abstain**.  
   • Review your selections and tap **Submit Vote**.  
   • Votes are encrypted and stored; you can only vote once per election.  
   • A confirmation screen will appear on success.

6. **Viewing Results**  
   • When results are public, select **Results** from the navigation bar.  
   • See total votes and percentages per candidate, with progress bars for quick insight.

7. **Account Management**  
   • From the **Account** tab, update your profile, toggle notifications, or log out.  
   • The **About** section lists app version & copyright.

### Administrator Guide

Administrators have elevated privileges determined by their `role = 'admin'` in the users table / Firestore document.

1. **Admin Dashboard**  
   After login, administrators are redirected to the **AdminScreen** (`lib/admin_screen.dart`).

2. **Key Functions**
   • **Manage Candidates** – Add, edit, or remove candidates for each position.  
   • **Enable / Disable Voting** – Toggle the election state. When disabled, voters cannot cast ballots.  
   • **View Live Results** – Real-time charts display vote counts and percentages.  
   • **Reset Election** – Clear all votes to begin a fresh election cycle.

3. **Data Flow**
   • All candidate & vote operations are written to **Cloud Firestore** when online.  
   • In offline/web DEMO mode, data is stored in in-memory lists and persisted to **SharedPreferences** for page reload durability.

4. **Security Measures**
   • Only authenticated admins can modify election data.  
   • Votes are write-only for voters; they cannot view or alter their ballots after submission.

---

## Data Model & Storage

### Firestore Collections

| Collection | Document ID | Fields |
|------------|------------|--------|
| `users`    | `uid`       | `name`, `email`, `role`, `hasVoted`, `createdAt` |
| `candidates` | `candidateId` | `name`, `year`, `position`, `description`, `imageUrl` |
| `votes`    | auto-id     | `userId`, `president`, `vicePresident`, `secretary`, `timestamp` |

### Local Fallback (Web / Offline)

`DatabaseHelper` detects web / connectivity issues and switches to:

1. **sqflite_common_ffi_web** for IndexedDB (web) or **sqflite** for mobile/desktop.  
2. In total offline demo cases on web, a **SimpleMockDatabase** stores data in memory and persists snapshots to **SharedPreferences**.

---

## Security & Privacy

• Passwords are hashed via Firebase Auth; they are **never** stored locally in plaintext.  
• API calls to Firebase are TLS encrypted.  
• Votes are anonymous – user IDs are stored separately from voting data.  
• Local fallback encrypts SharedPreferences using platform-level storage (for demo only – not production-grade).

---

## Contributing

1. Fork the repository & create a feature branch.  
2. Run `flutter format . && flutter analyze && flutter test` before opening a PR.  
3. Ensure new features respect existing architecture (services + UI) and include tests where applicable.

---

## License

This project is released under the MIT License – see [LICENSE](LICENSE) for details.
