# Chotto Pathshala

**শেখা হোক আনন্দের গল্প**

Chotto Pathshala is a Flutter-based, offline-first learning app for children. Lessons, reading, pictures, words, games and quizzes support Playgroup, Nursery, KG, Class 1 and Class 2.

## Learning and reading

- 498 bundled lesson entries: 389 core curriculum lessons, 104 additional Nursery alphabet lessons and 5 Arabic foundation lessons.
- 1,024 quiz questions with answer keys and explanations.
- Lesson objectives, stories, examples, activities, practice, answers and parent tips.
- Bangla, English and Arabic translations where available; missing translations fall back to the authored lesson text.
- Reading Mode: a distraction-light reader for lesson sections, adjustable text size, adjustable speech rate, read-all, read-section and stop controls.
- Read Aloud tries a keyless online Edge neural voice API first (Bangla, English and Arabic), then automatically falls back to the device's installed TTS voice if the API, network or MP3 playback fails. The Reading Mode switch can disable online speech. When enabled, lesson text is sent to the third-party voice service; use device-only mode for offline/private reading. See [Read Aloud TTS](docs/READ_ALOUD_TTS.md).
- Subject-based games, word/image cards, local lesson progress and five visual themes.
- Bundled lessons and quizzes work offline. YouTube feed refresh requires an internet connection.

## Video learning library

The bundled catalogue currently contains 1,638 unique candidate video records. All 1,638 are PENDING_REVIEW; the catalogue currently has 0 approved videos and 0 child-playable videos. The 2,000 figure is parser/library capacity, not the current approved count.

The previous video-discovery workflow has been restored with safer behaviour:

- 36 configured channel/feed sources. Feed refresh is manual (tap Refresh); the app does not contact feeds automatically at startup. Each reachable feed may return up to 15 recent entries, but the number varies and some legacy username feeds may no longer resolve.
- Feed titles and video IDs are imported as local review candidates only. Feed discovery does not confirm age suitability, Made for Kids status, embedding availability, teaching/religious accuracy, or usage rights.
- A user may add a YouTube URL or ID with a title, subject, language and format. It is saved locally as PENDING_REVIEW.
- Search, subject, language, format and review-status filters, bookmarks, pagination and locally removable user/feed candidates are available.
- No auto-approval, hover autoplay or automatic playback. Imported and user-added videos remain locked until every per-video review field and the separate app-level child-directed YouTube client gate are satisfied.
- The global YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED build flag defaults to false. Do not enable it until the app owner completes the required Google notification/privacy work and each individual video has been reviewed.

Windows/Linux use the supported browser fallback for eligible videos; embedded player availability depends on platform and build. YouTube may display ads or platform UI that the app cannot fully control. See [Video Playback Setup](docs/VIDEO_PLAYBACK_SETUP.md), [Video Library](docs/VIDEO_LIBRARY_1000.md), and the [video review register](docs/VIDEO_CONTENT_REVIEW.csv).

## Child-safety release mode

A multilingual in-app privacy policy is available from Settings. The public policy page is prepared at:

https://nazim-assdi.github.io/Chotto-Pathshala-0.1/privacy-policy.html

Deploy the public page through GitHub Pages before submitting the app to Play Console. Follow [Play Store release](docs/PLAY_STORE_RELEASE.md) and [Families compliance](docs/FAMILIES_COMPLIANCE.md).

## Project structure

- lib/ — Flutter/Dart application source
- assets/ — application images, icons and the video candidate catalogue
- app/src/main/assets/content/ — bundled lesson and quiz JSON
- test/ — Flutter tests
- tool/ — asset, video audit and child-safety scripts
- scripts/ — content validation utilities
- docs/ — release, privacy, Data Safety, Families and content-review documents
- .github/workflows/ — Flutter, web, audit and Play Store build workflows

The repository uses Flutter for the current application. Older Kotlin Android, Compose Desktop and Swift iOS implementations are not part of this codebase.

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
- Current app version: 1.3.9+15
- Android application ID: com.ntech.chotto_pathshala
- Target API: Android 16 / API 36
- Upload signing uses GitHub Actions secrets; never commit a keystore.

Create an upload key with tool/generate_play_store_keystore.ps1 and configure the four secrets documented in [PLAY_STORE_RELEASE.md](docs/PLAY_STORE_RELEASE.md). Without those secrets, the workflow creates an unsigned diagnostic artifact that must not be uploaded to Play Console.

## GitHub Actions

- Flutter builds — Android release APK and Windows builds.
- Chotto Pathshala - Play Store AAB — static child-safety check, Flutter analysis and tests, and an AAB build. The AAB is upload-ready only after signing verification succeeds.
- Flutter Web Preview — Flutter web preview.
- YouTube public video metadata audit — keyless, read-only public metadata triage; it does not approve videos.
- Publish Chotto Pathshala Privacy Policy — deploys the static privacy page when GitHub Pages is configured for GitHub Actions.

Open the repository Actions tab to inspect current build statuses and artifacts.

## Content validation

```bash
python scripts/validate_content.py
```

Automated JSON validation checks structural integrity. It does not replace human review of age suitability, teaching accuracy, religious accuracy or curriculum alignment.

## Child-safety and release review

- docs/PRIVACY_POLICY.md — human-readable privacy policy source.
- docs/privacy-policy.html — public static privacy policy in Bangla, English and Arabic.
- docs/DATA_SAFETY.md — evidence checklist for Play Console Data Safety.
- docs/FAMILIES_COMPLIANCE.md — Google Play Families release checklist and remaining blockers.
- docs/VIDEO_CONTENT_REVIEW.csv — per-video review register.
- docs/READ_ALOUD_TTS.md — online neural TTS, device fallback, privacy and troubleshooting.
- docs/VIDEO_LIBRARY_1000.md — video catalogue capacity, candidate workflow and approval gate.
- docs/VIDEO_PLAYBACK_SETUP.md — player gates and release requirements.
- tool/check_child_safety.py — release-time static safety check.
- tool/configure_android_release.py — Android application ID, target API, signing and child-release permission configuration.

The structured content audit checks completeness and integrity, not independent curriculum/age-suitability approval. Production release still requires educational review, a fully reviewed video register (if videos are to be played), verified TTS availability, a public privacy page, completed Play Console declarations and a signed/verified AAB.
