# JRNL (Flutter)

JRNL is a journaling + reflection app UI prototype built in Flutter.

## Getting Started

### Prerequisites
- Flutter SDK (uses Dart `^3.10.7`, see `pubspec.yaml`)
- Xcode (iOS) / Android Studio toolchain (Android), depending on your target

### Install deps
```sh
flutter pub get
```

### Run
```sh
flutter run
```

### Quality checks (for submission)
```sh
dart analyze
flutter test
```

To generate coverage:
```sh
flutter test --coverage
```

## Screenshots
Add screenshots here for your PDF/submission (home, journal, insights, leaderboard, profile).

## Notes on keys/secrets
- Do not commit API keys or service credentials.
- Firebase config files (e.g. `google-services.json`, `GoogleService-Info.plist`) should be generated from your Firebase project and added per your course requirements.

## Flavors (dev/prod)
Android flavors are `dev` and `prod`.

Examples:
```sh
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart
```

## Firebase Auth (Email/Password)
To enable sign-in/sign-up:
- Firebase Console → Build → Authentication → Get started
- Enable **Email/Password**
- (Recommended) Enable **Email verification** in your sign-up flow (this app gates the main UI until verified).

## Password reset
`Forgot password?` on the sign-in screen sends a reset email via Firebase Auth.

## Google Sign-In (iOS)
1) Firebase Console → Authentication → Sign-in method → enable **Google**
2) Re-download `GoogleService-Info.plist` if needed and ensure it contains `CLIENT_ID` and `REVERSED_CLIENT_ID`
3) Ensure `ios/Runner/Info.plist` includes `CFBundleURLTypes` with `REVERSED_CLIENT_ID` as a URL scheme

## Firestore (Users + Prompts)
1) Firebase Console → Build → **Firestore Database** → Create database
2) Create collections:
   - `users/{uid}` (public-ish profile fields like `displayName`, `photoUrl`, `xpTotal`, `streakCount`, `tier`, `createdAt`)
   - `users/{uid}/entries/{entryId}` (`promptText`, `bodyText`, `mode`, `createdAt`, `updatedAt`, optional `energyIndex`/`moodIndex`/`internalIndex`)
   - `prompts/{promptId}` (`text`, `date`, `active`)
3) Security rules (starter):
   - allow signed-in users to read `prompts`
   - allow users to read/write their own `users/{uid}` doc and `users/{uid}/entries/*`

Example rules:
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /prompts/{promptId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
      match /entries/{entryId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
}
```

### Codegen (freezed/json)
After pulling deps:
```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```
