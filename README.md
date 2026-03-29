# JRNL (Flutter)

JRNL is a journaling + reflection app built in Flutter.

## Getting Started

### Prerequisites
- Flutter SDK (uses Dart `^3.10.7`, see `pubspec.yaml`)
- Xcode (iOS) / Android Studio toolchain (Android), depending on your target
- Node.js (for Firebase emulators + Functions local build)

### Install dependencies
```sh
flutter pub get
```

### Run
```sh
flutter run
```

### Run Firebase locally (Emulators)
This project supports a no-Billing development workflow using Firebase Emulators (Auth/Firestore/Functions/Storage).

Start emulators (from project root):
```sh
# Functions are TypeScript — install + build once before starting emulators:
npm --prefix functions install
npm --prefix functions run build

GEMINI_API_KEY="YOUR_KEY" GEMINI_MODEL="gemini-2.5-flash-lite" \
  npx firebase-tools emulators:start --project demo-jrnl --only auth,firestore,functions,storage
```

Seed demo data (optional; creates `prompts/*` and a few `users/*` documents):
```sh
curl -X POST http://127.0.0.1:5001/demo-jrnl/us-central1/seedEmulatorData
```

Run the app against emulators (iOS Simulator):
```sh
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Physical iPhone on the same Wi‑Fi (use your Mac’s LAN IP):
```sh
flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=FIREBASE_EMULATOR_HOST=192.168.x.x
```

Optional dev-only mocks:
```sh
flutter run --dart-define=USE_MOCK_DATA=true
```

### Quality checks
```sh
dart analyze
flutter test
```

To generate coverage:
```sh
flutter test --coverage
```

Filtered coverage report (focuses on non-UI code):
```sh
chmod +x tool/coverage_filtered.sh
./tool/coverage_filtered.sh
```

## Screenshots
{Our screenshots will be here later.}

## ERD + Rules
- Firestore ERD: `docs/firestore_erd.md`
- Security rules summary: `docs/security_rules.md` (source files: `firestore.rules`, `storage.rules`)
- Known limitations: `docs/known_limitations.md`

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
   - `users/{uid}` (profile fields like `displayName`, `photoUrl`, `xpTotal`, `streakCount`, `tier`, `createdAt`)
   - `users/{uid}/entries/{entryId}` (`promptText`, `bodyText`, `mode`, `createdAt`, `updatedAt`, optional `energyIndex`/`moodIndex`/`internalIndex`)
   - `prompts/{promptId}` (`text`, `date`, `active`)

Notes:
- The app auto-creates `users/{uid}` on first sign-in.
- Add at least 1 active prompt doc so Home/Journal can show a real reflection prompt.
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
