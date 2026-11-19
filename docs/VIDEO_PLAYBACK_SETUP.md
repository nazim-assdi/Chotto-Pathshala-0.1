# Chotto Pathshala — Video Playback Setup

Date: 19 November 2026

## Implemented

- Official YouTube IFrame Player API via `youtube_player_iframe 6.0.2`.
- Lazy player creation: the list does not create a player. The player is constructed only after an explicit Play-button tap.
- Built-in YouTube controls, fullscreen button, privacy-enhanced player host and same-channel related-video restriction.
- Android `INTERNET` permission is retained for the embedded player; unrelated sensitive permissions remain stripped.
- Windows and Linux use an explicit user-tap fallback to open the video in the external browser.
- No hover autoplay and no playback when a card is merely tapped.

## Two independent gates

A video must pass both:

1. Per-video catalogue review:
   - `review_status = APPROVED`
   - non-empty `age_band`
   - `made_for_kids_status = CONFIRMED_MADE_FOR_KIDS`
   - `rights_check = CONFIRMED`
   - `embedding_status = CONFIRMED_EMBEDDABLE` from the official YouTube Data API.

2. App-level YouTube child-directed client configuration:
   - Owner must complete YouTube's notification of the child-directed API Client to Google.
   - Owner must complete the privacy and data-collection setup for embedded Made for Kids videos.
   - Only after that, set the compile-time define:
     `--dart-define=YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED=true`

The define defaults to false in all normal/CI builds. Do not set it true without actually completing Google's required notification and privacy work. It is not a substitute for per-video review.

## Current catalogue status

1,638 unique candidate records; all are PENDING_REVIEW. There are zero approved/playable records. Therefore the player implementation exists, but no current catalogue entry will play yet. This prevents review-pending content from being shown to children.

## Build examples

Safe default (player remains locked):
```bash
flutter build apk --release
```

Only after the app-level Google setup and after per-video reviews are complete:
```bash
flutter build apk --release --dart-define=YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED=true
```

A signed Play Store AAB must use the same define only after the same compliance gates are met. Inspect the merged Android manifest and the actual Data Safety disclosure before release.

## Policy references

- YouTube Developer Policies: https://developers.google.com/youtube/terms/developer-policies
- Made for Kids status lookup: https://developers.google.com/youtube/data/guides/made_for_kids_status
- Videos resource fields (including status.embeddable): https://developers.google.com/youtube/v3/docs/videos
- youtube_player_iframe 6.0.2 API: https://pub.dev/documentation/youtube_player_iframe/6.0.2/
