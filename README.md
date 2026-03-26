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
