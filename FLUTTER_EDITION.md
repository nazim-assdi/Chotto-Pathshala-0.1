# ছোট্ট পাঠশালা — Flutter Edition

এই repository-তে Flutter/Dart application-ই মূল অ্যাপ implementation।

## Technology

- Flutter stable এবং Dart
- Material UI
- Bundled local JSON lessons and quizzes
- SharedPreferences for on-device progress
- Flutter TTS for device-supported speech
- Offline-first learning experience

## Run locally

```bash
flutter create --platforms=android,windows,web .
flutter pub get
flutter analyze
flutter test
flutter run
```

Android APK:

```bash
flutter build apk --release
```

Windows:

```bash
flutter build windows --release
```

## Content

Lesson and quiz JSON files are stored in `app/src/main/assets/content/` and declared as Flutter assets in `pubspec.yaml`. Do not remove these files unless the corresponding asset declarations and application code are updated.

## Builds

GitHub Actions workflows in `.github/workflows/` build Android, Windows and Web outputs from the Flutter project.
