# Chotto Pathshala — Google Play Families release checklist

Audit date: 19 November 2026  
Release branch: feature/advanced-learning

This checklist tracks implementation work. It is not a Google approval or legal certification.

## Changes made for the child-facing release

- [x] Add the official YouTube IFrame player behind per-video approval and a separate false-by-default child-directed-client build gate.
- [x] Create the player only after a user presses the explicit Play button; never start on hover, page open or card tap.
- [x] Use YouTube's privacy-enhanced player host, keep YouTube controls and branding visible, and restrict related videos to the same channel.
- [x] Add Android INTERNET permission for the embedded player while removing unrelated sensitive permissions from the generated Android manifest.
- [x] Keep hover autoplay and automatic channel-feed discovery disabled.
- [x] Disable Android app-data backup and cleartext traffic in the generated release manifest.
- [x] Add an in-app privacy policy in Bangla, English and Arabic.
- [x] Add a public HTML privacy-policy page for Google Play listing use.
- [x] Remove the child-facing donation/payment card from Settings.
- [x] Add a video review register. Every previously bundled video is pending, and all channel sources are recorded as discovery candidates only.
- [x] Add a release-time static child-safety check.
- [x] Retire the old `yt-dlp` channel-page collection workflow and script; future YouTube metadata checks must use the official YouTube Data API.

## Must be completed before submitting to Google Play

- [ ] Enable GitHub Pages with Settings → Pages → Build and deployment → Source: GitHub Actions.
- [ ] Wait for the privacy-policy deployment workflow to succeed, then open the public URL and verify it works without login or download:
  https://nazim-assdi.github.io/Chotto-Pathshala-0.1/privacy-policy.html
- [ ] Add a working developer contact email to the Play Store listing. The public policy directs privacy requests to that listing contact.
- [ ] Inspect the final signed AAB and merged Android manifest. Confirm that no network or sensitive permission was merged by a dependency.
- [ ] Complete Play Console Target audience and content, App content, Ads, Data safety, and IARC content rating accurately for the exact release.
- [ ] Confirm whether the app is only child-directed and select the actual age groups. The app's learning design and store listing must match the declaration.
- [ ] Confirm that no advertising or advertising SDK is present. If ads are ever added, use only the relevant Google Play Families self-certified SDK versions for children and unknown-age users, and apply non-personalized child-directed treatment.
- [ ] Arrange a qualified human review of the lesson and quiz material for age appropriateness and accuracy. The existing content audit checks structure/integrity, not independent child-safety or curriculum suitability.
- [ ] Test the actual release build on Android for privacy, offline operation, navigation, speech and data transmission.

## Video library policy

The video catalogue currently contains 1,638 unique candidate video IDs (25 legacy records, 975 candidates from the first collection and 638 newly collected candidates). All 1,638 remain PENDING_REVIEW; 58 channel/feed sources are marked SOURCE_ONLY_NOT_APPROVED. There are zero approved/playable videos. The approval gate additionally requires an explicit per-video `CONFIRMED_EMBEDDABLE` status from YouTube's official API; missing or unknown embedding status fails closed. The Flutter catalogue parser supports up to 2,000 records. The UI displays category/language counts and lets parents filter by review status; this does not approve or unlock any video.

- [x] Restore search, dynamic subject filters generated from the catalogue with live counts, language filters with live counts, pending/approved/rejected status filters, lazy list rendering, video-ID search and locally stored bookmarks.
- [x] Add a single clear-filters action and show the correct review state on each video card.
- [x] Keep all legacy video records locked until an individual review is complete.
- [x] Keep automatic channel feeds and user-added video URLs disabled; desktop opens YouTube externally only after an approved Play tap.
- [x] Keep embedded player initialization blocked unless the owner confirms Google child-directed client notification and privacy setup through the build flag.
- [ ] Individually review each exact video ID and complete docs/VIDEO_CONTENT_REVIEW.csv, including the official API-backed `embedding_status` field.
- [ ] Reassess the current playback integration against the current Families policy, YouTube API terms, privacy and Data Safety disclosures before enabling the app-level build gate.

The app now contains the official YouTube IFrame player, but playback remains locked by default. `YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED` is a compile-time Dart define whose default is `false`; it must only be set to `true` after the app owner has notified Google that this is a child-directed YouTube API Client and completed the applicable privacy setup. The player is created only after an explicit Play-button tap, uses YouTube's privacy-enhanced host, shows YouTube's own controls and branding, and does not autoplay on hover, page load or card tap. Android INTERNET is included only to load the IFrame; unrelated sensitive permissions remain excluded. The current YouTube policies require looking up each embedded video's `status.madeForKids` and `status.embeddable` through the official Data API. A video must also pass the app's individual age-suitability and usage-rights review. The catalogue currently has 1,638 candidates, all PENDING_REVIEW, and zero approved/playable videos; therefore no current catalogue entry can play. Do not set the build flag to true until Google notification/privacy setup is actually complete and there are individually approved records. For a future compliant release, set `--dart-define=YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED=true` in the build only after that work. The previous `yt-dlp` channel-page collector has been retired; do not scrape YouTube channel pages. See `docs/VIDEO_PLAYBACK_SETUP.md` for the implementation and release steps.

## Known remaining release blockers

- The public privacy page must be deployed and the developer's contact email must be set on the Play listing.
- Data Safety must be verified against the final signed AAB and actual system TTS provider.
- Human content-suitability review of lessons/quizzes is not covered by the structural content audit.
- Google Play review and acceptance are determined by Google; a passing build or this checklist does not guarantee approval.
