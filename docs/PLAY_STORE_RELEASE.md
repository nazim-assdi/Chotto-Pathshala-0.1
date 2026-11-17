# Chotto Pathshala — Google Play release guide

## Current release configuration

| Setting | Value |
|---|---|
| App name | Chotto Pathshala |
| Version name | 1.3.4 |
| Version code | 10 |
| Android application ID | `com.ntech.chotto_pathshala` |
| Minimum Google Play target API | 36 (Android 16) |
| Preferred upload format | Android App Bundle (`.aab`) |

**Important:** the application ID is the permanent Play Store identity of this app once its first listing is created. Confirm that `com.ntech.chotto_pathshala` is the intended ID and is available in Play Console before creating the app listing. Do not change it after publishing.

## 1. Create an upload keystore

On Windows, open PowerShell in the repository folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\generate_play_store_keystore.ps1
```

The script creates `upload-keystore.jks` and `upload-keystore-base64.txt` in the current folder. Set a strong password, keep both files in a secure backup, and never commit them to Git.

## 2. Add GitHub Actions secrets

Open **GitHub → repository → Settings → Secrets and variables → Actions → New repository secret** and add:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Entire content of `upload-keystore-base64.txt` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `chotto-pathshala-upload` |
| `ANDROID_KEY_PASSWORD` | Key password (same as keystore password if you pressed Enter at the keytool prompt) |

Never paste the keystore or its passwords into a chat, issue, commit, or log. Keep an offline backup: losing the upload key can delay future updates.

## 3. Build the Play Store bundle

1. Open the repository's **Actions** tab.
2. Select **Chotto Pathshala - Play Store AAB**.
3. Select **Run workflow** and choose `feature/advanced-learning`.
4. Wait for the workflow to finish and download the `chotto-pathshala-play-store-aab` artifact.
5. Confirm the workflow says the upload bundle was signed. The signed artifact includes `app-release.aab` and its SHA-256 checksum.

If signing secrets are missing, the workflow deliberately builds a diagnostic unsigned bundle named `chotto-pathshala-unsigned-aab-preflight`. **That file cannot be uploaded to Play Console.** Add the four secrets and run the workflow again.

## 4. First-time Play Console setup

- Create the app listing and verify the permanent application ID before the first upload.
- Enrol in Play App Signing and upload the signed AAB with the upload key. New Play apps use Play App Signing.
- Complete the app content, target audience, content rating, Data safety, ads, app access and privacy policy declarations accurately.
- Add a high-resolution app icon, feature graphic, phone screenshots, title, short description and full description.
- Use internal testing first; test installation, offline lessons, Bengali/English/Arabic text and voice, video playback, orientation, low-memory devices and app updates.
- Check Play Console's current testing and account-verification requirements before requesting production access.

## 5. Child-safety and content review — required before publishing

This app is designed for young learners and contains an external video library/player. The repository documentation notes that video feeds are selected at channel/source level and that individual videos are not all manually reviewed. It also notes that there is no parent-mode lock or per-video approval gate. This is **not yet evidence of complete Families-policy readiness**.

Before selecting children as a target audience or publishing to a child-directed category:

- Review every bundled video and feed source for age-appropriate content; remove questionable or unreviewed sources and videos.
- Review YouTube playback, ads, external navigation and platform overlays in the actual app. Do not assume the app can control YouTube-served content.
- Decide whether parent-only controls and an adult gate are needed for video access, external links and settings.
- Publish a real privacy policy and verify every SDK, network request and data flow before completing Data safety.
- Complete the Families policy, Target Audience and Content, Data safety and IARC/content-rating questionnaires truthfully.

A generated AAB is a build artifact, not a guarantee that Google Play will approve the app.

## Store listing draft

**Title:** Chotto Pathshala

**Short description:** Fun Bangla, English and Arabic lessons, stories, games and quizzes for kids.

**Full description:**

Chotto Pathshala turns early learning into a joyful everyday adventure. Children can explore Bangla, English and Arabic, practise letters and words, enjoy stories and pictures, and build confidence through interactive activities and quizzes.

Highlights:
- Learning activities for Playgroup, Nursery, Kindergarten, Class 1 and Class 2.
- Bangla, English and Arabic learning content.
- Picture-based word learning and device text-to-speech where supported.
- Lessons, practice activities and quizzes.
- Progress saved locally on the device.
- Offline access to bundled lessons and quizzes.
- A video discovery library with external YouTube playback.

Some video content requires an internet connection and is provided by third-party services. Parents and caregivers should review video content and supervise children's use of external video services.

**Before using this text:** confirm the content is current, review child-safety controls and privacy practices, and ensure all store declarations accurately describe the final build.
