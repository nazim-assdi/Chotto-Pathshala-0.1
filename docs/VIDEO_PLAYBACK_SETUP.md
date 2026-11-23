# Chotto Pathshala — Video Playback Setup

Date: 21 November 2026

## Implemented

- Official YouTube IFrame Player API via \`youtube_player_iframe 6.0.2\`.
- Lazy player creation: the list does not create a player. A first-time user must accept the app Privacy Policy and YouTube Terms of Service in a consent dialog; only then is the player constructed after an explicit Load-player tap, with autoplay false.
- Built-in YouTube controls, fullscreen button, privacy-enhanced player host and same-channel related-video restriction.
- Android \`INTERNET\` permission is retained for the embedded player; unrelated sensitive permissions remain stripped.
- Windows and Linux use an explicit user-tap fallback to open the video in the external browser.
- No hover autoplay and no playback when a card is merely tapped. Start playback with YouTube's own built-in Play control after the player loads.

## Consent requirement

Before first access, a modal consent dialog links to the app Privacy Policy, app Terms of Use, YouTube Terms of Service and Google Privacy Policy. Both app privacy and YouTube terms checkboxes are required. Consent is stored locally in SharedPreferences under a versioned key. The public terms page states that using the YouTube feature means agreeing to YouTube's Terms of Service.

## Two independent gates

A video must pass both:

1. Per-video catalogue review:
   - \`review_status = APPROVED\`
   - non-empty \`age_band\`
   - \`made_for_kids_status = CONFIRMED_MADE_FOR_KIDS\`
   - \`rights_check = CONFIRMED\`
   - \`embedding_status = CONFIRMED_EMBEDDABLE\` from authoritative YouTube evidence.

2. App-level YouTube child-directed client configuration:
   - Owner must complete YouTube's notification of the child-directed API Client to Google.
   - Owner must complete the privacy and data-collection setup for embedded Made for Kids videos.
   - Only after that, set the compile-time define:
     \`--dart-define=YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED=true\`

The define defaults to false in all normal/CI builds. Do not set it true without actually completing Google's required notification and privacy work. It is not a substitute for per-video review.

## On-device Video Review Dashboard

Open the checklist icon in the Video Library toolbar. The review dashboard has no PIN and is intended for an adult operator; anyone holding the device can change its local review records, so do not leave it open for a child to use unattended.

For each candidate, use **Preview video** to open YouTube in the external browser/app and watch the full video. Return to the app, choose the appropriate class band, and only confirm the checklist items when evidence has actually been checked: full-video age suitability, YouTube Made for Kids status, permission/licence to include the video, and YouTube embedding permission. Enter the reviewer and evidence notes. Approve stays disabled until every check, class band, reviewer and evidence note are present. Save as pending preserves incomplete work; Reject requires a reason.

Review decisions are saved locally under `video_library_review_records_v1` and merged back into the bundled catalogue at load time. They do not modify the repository's bundled JSON or synchronize to another device. Imported candidates still enter the queue as pending and cannot self-approve.

The dashboard removes the need for a separate parent PIN during review/playback, but **it does not bypass Google's app-level child-directed client configuration**. The build flag remains false by default. Even individually approved records remain unavailable to the child player until the app owner completes the required Google notification and privacy setup, then produces a build with the documented define. The first-use YouTube Privacy Policy/Terms consent dialog is a separate service/legal consent step, not a parent PIN.

## Restored candidate discovery and manual additions

The Video library restores the historic 36 configured channel/feed sources. Refresh is explicit and user initiated; no feeds are contacted during app startup. Where a feed responds, its Atom video title/ID is saved to the device as a `CHANNEL_FEED` candidate. Some old username-based feed URLs may not resolve. Web preview may block feed requests because of browser CORS restrictions.

The Add YouTube URL action accepts a valid YouTube watch, Shorts, embed, live or short URL (or an 11-character ID) and saves it locally as a `USER_ADDED` candidate. Subject, language and format filters are available. Candidate deletion and bookmarks are local.

Both imports always clear/override review fields to `PENDING_REVIEW`, blank age band/rights, `NOT_CHECKED` Made for Kids and `NOT_CHECKED` embedding. They can never grant approval. Discovery metadata is not a content review. No API key is needed for the public Atom feed request itself; this does not remove the Google notification/privacy requirements for the embedded player.

## Current catalogue status

The bundled catalogue has 1,638 unique candidate records; all are PENDING_REVIEW. The dashboard shows the current total including locally imported candidates. There are zero approved/playable records at the time of this audit. Therefore the player implementation exists, but no current catalogue entry will play yet. This prevents review-pending content from being shown to children.

## Keyless public metadata preflight

See [VIDEO_API_AUDIT.md](VIDEO_API_AUDIT.md). It uses YouTube's public oEmbed endpoint and needs no API key. It can compare public titles/channels and flag lookup failures. It cannot confirm Made for Kids status, authoritative embedding permission, complete video content, age suitability or usage rights. Those required fields must remain NOT_CHECKED until separately verified.

## Build examples

Safe default (player remains locked):
\`\`\`bash
flutter build apk --release
\`\`\`

Only after the app-level Google setup and after per-video reviews are complete:
\`\`\`bash
flutter build apk --release --dart-define=YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED=true
\`\`\`

A signed Play Store AAB must use the same define only after the same compliance gates are met. Inspect the merged Android manifest and the actual Data Safety disclosure before release.

## Policy references

- YouTube Help — embed videos and child-oriented app self-designation: https://support.google.com/youtube/answer/171780
- YouTube IFrame Player API: https://developers.google.com/youtube/iframe_api_reference
- YouTube Developer Policies: https://developers.google.com/youtube/terms/developer-policies
- Made for Kids status lookup: https://developers.google.com/youtube/data/guides/made_for_kids_status
- Videos resource fields (including status.embeddable): https://developers.google.com/youtube/v3/docs/videos
- youtube_player_iframe 6.0.2 API: https://pub.dev/documentation/youtube_player_iframe/6.0.2/

## Reading Mode

Lesson Reading Mode is opened from the book icon in a lesson. It displays the lesson sections in a focused reader with adjustable font size and speech rate, read-all, read-one-section and stop controls. Read Aloud tries the public no-key Edge-TTS MCP endpoint first, using Bangla (`bn-BD-NabanitaNeural`), English (`en-US-AriaNeural`) or Arabic (`ar-SA-ZariyahNeural`) neural voices. If the endpoint, connection, browser CORS or MP3 playback fails, it automatically falls back to the device-installed `flutter_tts` voice. The “Try online voice API first” switch is enabled by default and can be turned off in Reading Mode. When enabled, selected built-in lesson text and speech settings are sent to the third-party service; its public demo is unauthenticated and best-effort, and the provider says generated audio files are deleted after 24 hours. See [Read Aloud TTS](READ_ALOUD_TTS.md).
