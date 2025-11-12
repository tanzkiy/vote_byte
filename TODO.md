# Remove Firebase Integration from BYTE Voting App

## Tasks to Complete

- [ ] Update pubspec.yaml: Remove Firebase dependencies (firebase_core, firebase_auth, cloud_firestore, firebase_core_platform_interface)
- [ ] Update lib/main.dart: Remove Firebase import and initialization
- [ ] Delete lib/services/firebase_service.dart
- [ ] Update lib/services/auth_service.dart: Replace Firebase auth with local SharedPreferences-only implementation
- [ ] Update lib/services/voting_service.dart: Replace Firebase voting operations with local storage using SharedPreferences
- [ ] Test the app to ensure functionality works without Firebase

## Notes
- Authentication will now use only SharedPreferences for storing user data locally
- Voting data will be stored locally using SharedPreferences
- Candidates data is already local in voting_service.dart
- Admin features will work with local data
