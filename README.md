# জ্ঞানবাড়ি (Gyanbari)

A child-friendly, offline-first Android learning app for Playgroup, Nursery, KG and Class One, built with Kotlin and Jetpack Compose.

## Current app foundation

- Native Android application with Bengali interface.
- Four learning levels: Playgroup, Nursery, KG and Class One.
- Lesson and quiz content loaded from local JSON assets.
- Lesson reader with objectives, stories, examples, activities, practice and answer reveal.
- Subject-wise and level-wise lesson and quiz selection.
- Picture-word learning cards and a picture-matching game.
- Five visual themes and an Eye Comfort setting.
- Android Text-to-Speech (TTS) integration for supported installed voices.
- Lesson narration and quiz question/option/explanation playback.
- Adjustable TTS speech rate: slow, normal and fast.
- Mixed-script narration switches between supported Bangla, English and Arabic voices where the device TTS engine provides them.
- Local settings saved on the device.

## Curriculum direction

The curriculum is being developed as an original Bangladesh-focused learning pathway informed by the learning principles and public learning frameworks of:

- Cambridge Early Years and Primary
- International Baccalaureate Primary Years Programme (IB PYP)
- Montessori
- UNICEF foundational learning
- England's Early Years Foundation Stage (EYFS)

These are reference frameworks, not claims of accreditation, endorsement or official affiliation. Gyanbari lessons must be original and age-appropriate, with Bangla, English, early mathematics, environmental/science learning, Arabic/Islamic and moral learning, creative work, health, safety and local-life themes. Do not reproduce copyrighted textbook passages or proprietary curriculum materials.

See [the curriculum design brief](content/curriculum/CURRICULUM_FRAMEWORK.md).

## Voice and offline audio: current limitation

The app currently uses the Android device's installed Text-to-Speech engine. It can speak supported text when a compatible language voice is installed. The app does **not yet** download and manage its own Bangla, English or Arabic audio packs, and cannot guarantee offline voice availability on every phone.

A future app-managed audio system must:
1. Ask for consent before downloading voice assets.
2. Download licensed/generated audio securely and show language/pack size and progress.
3. Verify files and store them in app-private storage.
4. Play cached audio offline, with Android TTS or an approved online service as fallback.
5. Keep API credentials out of the APK; provider access must be mediated securely.

## Build the debug APK

1. Install Android Studio and Android SDK Platform 35.
2. Open this repository folder in Android Studio.
3. Let Gradle sync finish.
4. Select **Build > Build Bundle(s) / APK(s) > Build APK(s)**.
5. The APK is normally created at `app/build/outputs/apk/debug/app-debug.apk`.

## Automated build

The GitHub Actions workflow builds a debug APK on pushes and pull requests. A build has not been run as part of this change.
