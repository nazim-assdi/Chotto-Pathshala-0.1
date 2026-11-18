# Chotto Pathshala — Google Play Families release checklist

Audit date: 17 November 2026  
Release branch: feature/advanced-learning

This checklist tracks implementation work. It is not a Google approval or legal certification.

## Changes made for the child-facing release

- [x] Disable the video tab's video playback and automatic channel-feed discovery.
- [x] Remove the embedded YouTube player and desktop WebView player source files.
- [x] Remove direct YouTube/network-player dependencies from pubspec.yaml.
- [x] Remove app network permission and unnecessary sensitive permissions from the generated Android main manifest during release configuration.
- [x] Keep autoplay disabled until each candidate has individual child-suitability, Made for Kids and rights verification.
- [x] Disable Android app-data backup and cleartext traffic in the generated release manifest.
- [x] Add an in-app privacy policy in Bangla, English and Arabic.
- [x] Add a public HTML privacy-policy page for Google Play listing use.
- [x] Remove the child-facing donation/payment card from Settings.
- [x] Add a video review register. Every previously bundled video is pending, and all channel sources are recorded as discovery candidates only.
- [x] Add a release-time static child-safety check.

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

The video catalogue currently contains 1,638 unique candidate video IDs (25 legacy records, 975 candidates from the first collection and 638 newly collected candidates). All 1,638 remain PENDING_REVIEW; 58 channel/feed sources are marked SOURCE_ONLY_NOT_APPROVED. There are zero approved/playable videos. The Flutter catalogue parser supports up to 2,000 records.

- [x] Restore search, subject filters, lazy list rendering and locally stored bookmarks.
- [x] Keep all legacy video records locked until an individual review is complete.
- [x] Keep automatic channel feeds, external player links and user-added video URLs disabled.
- [x] Keep the player package and INTERNET permission out of this child-facing build.
- [ ] Individually review each exact video ID and complete docs/VIDEO_CONTENT_REVIEW.csv.
- [ ] Reassess any future playback integration against the current Families policy, YouTube API terms, privacy and Data Safety disclosures before enabling it.

A YouTube embedded player cannot fully suppress related videos; its rel=0 behaviour only limits recommendations to the same channel. YouTube ads and data processing are not controlled by this app. YouTube's current developer policies require the app to look up each embedded video's Made for Kids status, and autoplay transfers data on page load. Autoplay must not start until more than half of the player is visible, and only one player may autoplay on a screen at a time. A child-directed API client must also be notified to Google and comply with applicable child-privacy law. A hover-triggered player start is therefore not being implemented; use visibility-based autoplay only after the complete compliance gate is met. See docs/VIDEO_LIBRARY_1000.md before considering any player implementation.

## Known remaining release blockers

- The public privacy page must be deployed and the developer's contact email must be set on the Play listing.
- Data Safety must be verified against the final signed AAB and actual system TTS provider.
- Human content-suitability review of lessons/quizzes is not covered by the structural content audit.
- Google Play review and acceptance are determined by Google; a passing build or this checklist does not guarantee approval.
