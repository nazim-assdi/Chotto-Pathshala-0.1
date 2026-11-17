# Chotto Pathshala — Google Play Families release checklist

Audit date: 17 November 2026  
Release branch: feature/advanced-learning

This checklist tracks implementation work. It is not a Google approval or legal certification.

## Changes made for the child-facing release

- [x] Disable the video tab's video playback and channel-feed discovery.
- [x] Remove the embedded YouTube player and desktop WebView player source files.
- [x] Remove direct YouTube/network-player dependencies from pubspec.yaml.
- [x] Remove app network permission and unnecessary sensitive permissions from the generated Android main manifest during release configuration.
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

## Video policy

The previous source contained 25 bundled YouTube video entries and 42 channel/feed sources. Neither channel-level branding nor a video title establishes that an individual video is suitable for a child.

The child-facing release therefore ships with videos disabled. Do not re-enable automatic channel feeds. Before adding a video later, a reviewer must watch the full video and record at minimum:

1. Stable video ID, title, creator/channel, language and intended age band.
2. Full-content review notes: violence, frightening themes, sexual content, dangerous imitation, discriminatory material, language, commercial messaging and any other age-suitability issue.
3. YouTube's Made for Kids status checked for that individual video where the YouTube player/API is used.
4. Advertising, recommendations, external navigation, privacy and playback behaviour.
5. Rights/permission basis and reviewer's name/date.
6. Explicit approval for the specific ID in the child-facing allowlist.

A channel feed must never be trusted as an automatic child-safe allowlist. Keep every row in docs/VIDEO_CONTENT_REVIEW.csv pending until an actual human review is complete.

## Known remaining release blockers

- The public privacy page must be deployed and the developer's contact email must be set on the Play listing.
- Data Safety must be verified against the final signed AAB and actual system TTS provider.
- Human content-suitability review of lessons/quizzes is not covered by the structural content audit.
- Google Play review and acceptance are determined by Google; a passing build or this checklist does not guarantee approval.
