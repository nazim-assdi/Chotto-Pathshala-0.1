# জ্ঞানবাড়ি (Gyanbari)

An offline-first Android learning library for children. This repository contains the initial Android app foundation.

## Current starter features
- Native Android app built with Kotlin and Jetpack Compose.
- Bengali home screen and six subject categories.
- A sample lesson displayed locally; the app does not require an account or network connection to open.

## Planned roadmap
- 365 genuinely distinct, complete daily lessons with stories, examples, exercises and answer keys.
- At least 1,000 genuinely distinct MCQs with explanations and answer validation.
- Bangla, English and Arabic reading support and audio.
- Offline audio packs using properly licensed recordings, plus Android Text-to-Speech offline-voice detection.
- PDF reading, printing and local learning-progress storage.

The roadmap items are not yet implemented. Audio recordings and offline TTS voice data are not bundled in this starter version. Android offline TTS depends on a compatible voice installed on the device.

## Build the debug APK
1. Install Android Studio and Android SDK Platform 35.
2. Open this repository folder in Android Studio.
3. Let Gradle sync finish.
4. Select Build > Build Bundle(s) / APK(s) > Build APK(s).
5. The APK is normally created at app/build/outputs/apk/debug/app-debug.apk.

## Automated build
A GitHub Actions workflow builds the debug APK on pushes and pull requests. Open the Actions tab and download the artifact from a successful workflow run.
