# Chotto Pathshala — Google Play release guide

## Current child-facing release configuration

| Setting | Value |
|---|---|
| App name | Chotto Pathshala |
| Version name | 1.3.6 |
| Version code | 12 |
| Android application ID | com.ntech.chotto_pathshala |
| Target API | 36 |
| Upload format | Android App Bundle (.aab) |
| Video catalogue | 25 legacy records, 0 approved/playable; 1,000 target capacity |
| App data storage | Local app preferences and progress |
| Advertising / analytics SDKs | None configured in app dependencies |

The application ID is the permanent Play Store identity after first publication. Confirm it is correct before creating the Play Console listing.

## 1. Child-safety changes in this branch

- The app previously contained 25 bundled YouTube videos and 42 channel/feed sources. The source feeds were automatically importing recent uploads without individual video review.
- The old video tab is restored as a 1,000-record-capacity searchable catalogue with local bookmarks. The current register has 25 legacy video IDs, all PENDING_REVIEW; 42 channel/feed sources are candidate-only. There are 0 approved/playable videos. Automatic feeds, video playback, external player links and custom video addition remain disabled.
- A per-video review register is provided at docs/VIDEO_CONTENT_REVIEW.csv. The 25 video records remain PENDING_REVIEW; 42 feed sources are SOURCE_ONLY_NOT_APPROVED.
- The Settings donation/payment panel was removed from the child-facing interface.
- A trilingual privacy policy is available inside Settings and as a static public page.
- The Play release workflow runs a static child-safety check and removes unnecessary network and sensitive permissions from the generated Android main manifest.

Do not enable playback or video feeds until individual content review and a new technical/policy review are complete. See docs/VIDEO_LIBRARY_1000.md for the catalogue model and approval gate.

## 2. Publish the public Privacy Policy

The public page is prepared at:

https://nazim-assdi.github.io/Chotto-Pathshala-0.1/privacy-policy.html

To deploy it:
1. Open GitHub repository Settings → Pages.
2. Under Build and deployment, select GitHub Actions as the source.
3. Open Actions and run or wait for “Publish Chotto Pathshala Privacy Policy”.
4. Verify that the URL above opens without signing in, on a normal HTTPS connection, and displays the full policy.
5. Put the same public URL in the Play Console Privacy Policy field.

The workflow being present in the repository does not mean the site has already been deployed. Check the workflow's successful deployment and open the public URL before using it in Play Console.

Add a working developer contact email to the Play listing before publication. The policy directs privacy requests to that listing contact.

## 3. Data Safety review

Use docs/DATA_SAFETY.md as an evidence worksheet, not as a prefilled Google declaration.

Before submitting the Data Safety form:
- Inspect the final signed AAB, all bundled SDKs and the merged Android manifest.
- Verify that no dependency adds network, advertising ID, precise location, camera, microphone or other unnecessary permissions.
- Test outbound network activity on a fresh Android install.
- Check the speech engine configured on the actual device. System text-to-speech may rely on an online provider outside this app's control.
- Make the privacy policy and Play Console answers consistent with the final package.

Do not claim “no data collected” until these checks confirm that the app and all SDKs do not transmit data off-device. If a future release adds online services, revise the privacy policy and Data Safety declaration before publishing.

## 4. Families and child-directed declarations

Complete Play Console Target audience and content, App content, Ads, Data Safety, app access and IARC content-rating declarations accurately for the actual app and selected age groups.

Before production:
- Read docs/FAMILIES_COMPLIANCE.md and complete each outstanding item.
- Arrange qualified human age-suitability review of lessons and quizzes. The current content audit validates structure and required fields, not child suitability, factual accuracy or curriculum alignment.
- Test the final release on Android, including offline operation, speech, themes, progress storage and navigation.
- Do not add child-directed advertising or cross-promotion without checking the current Families requirements and permitted self-certified SDKs.
- A successful CI build is not Google Play approval.

## 5. Create an upload keystore

On Windows, open PowerShell in the repository folder and run:

powershell -ExecutionPolicy Bypass -File .\tool\generate_play_store_keystore.ps1

The script creates upload-keystore.jks and upload-keystore-base64.txt in the current folder. Use a strong password, keep both files in a secure offline backup and never commit them to Git.

## 6. Add GitHub Actions secrets

Open GitHub → repository → Settings → Secrets and variables → Actions → New repository secret and add:

| Secret | Value |
|---|---|
| ANDROID_KEYSTORE_BASE64 | Entire content of upload-keystore-base64.txt |
| ANDROID_KEYSTORE_PASSWORD | Keystore password |
| ANDROID_KEY_ALIAS | chotto-pathshala-upload |
| ANDROID_KEY_PASSWORD | Key password |

Never paste the keystore or passwords into a chat, issue, commit or build log.

## 7. Build the Play Store bundle

1. Open the repository Actions tab.
2. Select “Chotto Pathshala - Play Store AAB”.
3. Select Run workflow and choose feature/advanced-learning.
4. Download chotto-pathshala-play-store-aab only when the workflow confirms upload-key signing and its signing verification step succeeds.
5. The artifact must contain app-release.aab and its SHA-256 checksum. The pack also contains the privacy policy, Data Safety worksheet, Families checklist and video review register.

If any signing secret is missing, the workflow creates chotto-pathshala-unsigned-aab-preflight. That is a diagnostic artifact only and cannot be uploaded to Play Console.

## Store listing draft

**Title:** Chotto Pathshala

**Short description:** Fun Bangla, English and Arabic lessons, stories, games and quizzes for kids.

**Full description:**

Chotto Pathshala makes early learning a joyful everyday adventure. Children can explore Bangla, English and Arabic, practise letters and words, enjoy stories and pictures, and build confidence through interactive activities and quizzes.

Highlights:
- Learning activities for Playgroup, Nursery, Kindergarten, Class 1 and Class 2.
- Bangla, English and Arabic learning content.
- Picture-based word learning and device text-to-speech where supported.
- Lessons, practice activities and quizzes.
- Progress saved locally on the device.
- Offline access to bundled lessons and quizzes.

Parents and caregivers can review the in-app privacy policy and should supervise children's use of device-level speech services.


Current video catalogue status (2026-11-18): 1,000 unique metadata candidates, all PENDING_REVIEW; 0 approved/playable. Collection of metadata is not a child-safety review. Do not enable playback or claim the video library is approved until each video is individually reviewed and rights are confirmed.
