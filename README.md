# Chotto Pathshala

**শেখা হোক আনন্দের গল্প**

Chotto Pathshala is a Flutter-based, offline-first learning app for children. It brings lessons, pictures, words, games and quizzes for Playgroup, Nursery, KG, Class One and Class Two into one place.

## Current learning features

- Bangla, English and Arabic letters and vocabulary with pictures and device voice support.
- Learning levels for Playgroup, Nursery, KG, Class 1 and Class 2.
- Lesson objectives, stories, examples, activities, practice and answer keys.
- Subject-based games and class-level quizzes.
- Lesson progress and app preferences saved locally on the device.
- Offline access to bundled lessons and quizzes.
- Trilingual interface and multiple visual themes.

## Child-safety release mode

The child-facing release currently **disables all YouTube video playback and automatic channel feeds**. The previous catalogue contained 25 bundled video IDs and 42 channel/feed sources, but those entries were not all individually reviewed. Do not restore videos or automatic feed discovery until each specific video has completed the review recorded in docs/VIDEO_CONTENT_REVIEW.csv.

The previous YouTube player and desktop WebView player implementations and direct dependencies have been removed. The Android Play release configuration removes unnecessary network and sensitive permissions. Settings no longer displays the donation/payment panel.

A multilingual in-app privacy policy is available from Settings. The public policy page is prepared at:
https://nazim-assdi.github.io/Chotto-Pathshala-0.1/privacy-policy.html

The public page must be deployed through GitHub Pages before it is submitted to Play Console. Follow docs/PLAY_STORE_RELEASE.md and docs/FAMILIES_COMPLIANCE.md.

## Project structure

- lib/ — Flutter/Dart application source
- assets/ — application images and visual assets
- app/src/main/assets/content/ — bundled lesson and quiz JSON data
- test/ — Flutter tests
- tool/ — asset, icon and child-safety release scripts
- scripts/ — content validation utilities
- docs/ — release, privacy, Data Safety, Families and content-review documents
- .github/workflows/ — Flutter and Play Store build workflows

The repository contains the Flutter project, content and required assets. Older Kotlin Android, Compose Desktop and Swift iOS implementations were removed.

## Run locally

Install the Flutter stable SDK, then run from the repository root:

```bash
flutter create --platforms=android,windows,web .
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Windows build:

```bash
flutter build windows --release
```

## Google Play release

- Android Play Store workflow: .github/workflows/play-store-aab.yml
- Upload format: signed Android App Bundle (.aab)
- Current release version: 1.3.5+11
- Android application ID: com.ntech.chotto_pathshala
- Target API: Android 16 / API 36
- Upload signing uses GitHub Actions secrets; never commit a keystore.

Before creating a signed bundle, create an upload key with tool/generate_play_store_keystore.ps1 and configure the four secrets documented in docs/PLAY_STORE_RELEASE.md. Without those secrets, the workflow creates an unsigned diagnostic artifact that must not be uploaded to Play Console.

## GitHub Actions

- Flutter builds — Android release APK and Windows builds.
- Chotto Pathshala - Play Store AAB — static child-safety check, Flutter analysis and tests, and an AAB build. The AAB is treated as upload-ready only after signing verification succeeds.
- Publish Chotto Pathshala Privacy Policy — deploys the static privacy page when GitHub Pages is enabled with GitHub Actions as its source.
- Flutter Web Preview — Flutter web preview.

Open the repository Actions tab to inspect build results and artifacts.

## Content validation

```bash
python scripts/validate_content.py
```

Automated JSON validation does not replace human review of age suitability, teaching accuracy, religious accuracy or curriculum alignment.

## Child-safety and release review

- docs/PRIVACY_POLICY.md — human-readable privacy policy source.
- docs/privacy-policy.html — public static privacy policy in Bangla, English and Arabic.
- docs/DATA_SAFETY.md — evidence checklist for the Play Console Data Safety form.
- docs/FAMILIES_COMPLIANCE.md — Google Play Families release checklist and remaining blockers.
- docs/VIDEO_CONTENT_REVIEW.csv — review register for 25 previously bundled videos and 42 channel/feed candidates.
- tool/check_child_safety.py — release-time static check.
- tool/configure_android_release.py — Android application ID, target API, signing and child-release permission configuration.

The existing structured content audit checks field completeness and integrity. It does not establish that every lesson or quiz has been independently reviewed for child suitability or factual accuracy. The release team must complete that human review and verify the final signed AAB, merged manifest, system text-to-speech provider, public privacy page and Play Console declarations before production.
