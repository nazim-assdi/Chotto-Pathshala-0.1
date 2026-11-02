# ছোট্ট পাঠশালা — Flutter Edition

The Flutter application is being introduced alongside the existing Kotlin Android and Compose Desktop projects. The existing native applications are not deleted or replaced.

## Technology

- Flutter (Dart) with Material 3 UI.
- Existing lesson and quiz JSON files are loaded as bundled local assets.
- SharedPreferences stores completed lesson day numbers on the device.
- Offline-first: lessons, quizzes and progress do not require an internet connection.

## Run locally

Install the Flutter stable SDK and enable the target desktop platform.

From the repository root:

```powershell
flutter doctor
flutter create --platforms=android,windows,web,linux,macos,ios .
flutter pub get
flutter run -d windows
```

For Android:

```powershell
flutter run -d android
flutter build apk --release
```

For Windows:

```powershell
flutter build windows --release
```

The Windows release output is in `build/windows/x64/runner/Release/`. It is a folder containing the executable and required runtime files; distribute it as a package/installer, not as a lone EXE.

## Current first milestone

- Grade selection for Playgroup, Nursery, KG, Class One and Class Two.
- Lesson search, lesson reader and completion tracking.
- Multiple-choice quiz with explanations and score.
- Existing local JSON curriculum reused directly from the Android content folders.

## Limitations / next milestones

- Class Two has 24 draft lessons and 24 draft questions; teacher review is still required.
- Existing progress from the Kotlin app is not automatically imported; the data stores are different.
- No cloud account or synchronization is connected yet.
- Text-to-speech, image-rich learning cards, parent dashboard, accessibility polish and installer signing are future tasks.
- iOS release signing requires macOS and Apple developer credentials.
