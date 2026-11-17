# 1,000-video library architecture

## What this release contains

The video section has been restored as a searchable, category-based catalogue. It is designed for up to 1,000 unique entries and renders records lazily, with a target page size of 20. It includes local bookmarks, category filters, search by title/channel/subject/language, and a review-status indicator.

The current manifest contains only the 25 legacy video IDs discovered in the repository's review register. All 25 remain PENDING_REVIEW; the 42 old channel/feed sources remain source candidates only and are never imported automatically. The app currently has **0 approved / playable videos**. The target of 1,000 is a catalogue capacity/goal, not a claim that 1,000 videos have been acquired.

## Adding a video

Add one record to assets/videos/video_catalog.json with these fields:

- video_id: stable 11-character YouTube video ID
- title, channel, subject, language
- review_status, age_band, made_for_kids_status, rights_check

Do not add a channel feed, playlist, search URL, or dynamically discovered uploads as an approved record. Each exact video ID must have a completed review record in docs/VIDEO_CONTENT_REVIEW.csv.

## Approval gate

A record can only be considered eligible for a later playback integration when its review status is APPROVED, an intended age band is recorded, the individual video's Made for Kids status is confirmed, and rights are confirmed. A qualified reviewer must also document the full-video review, advertising/recommendation behaviour, external navigation and privacy observations in the review register.

This release does not bundle a video player or network permission. The card tap deliberately shows a review notice. The YouTube embedded-player API does not provide a supported way to completely remove related videos; rel=0 only limits related videos to the same channel. Ads and YouTube-side processing are outside this app's control. Do not enable an embedded player in a child-directed release until the exact integration is re-assessed against the current Google Play Families policy, YouTube API terms, privacy disclosures and Data Safety answers.

## Data integrity

- Video IDs must match the 11-character YouTube ID pattern.
- Duplicate IDs and incomplete records are ignored by the loader.
- The loader caps catalogue input at 1,000 unique valid entries.
- Bookmarks are kept locally using SharedPreferences.
- No user-supplied video URL or automatic feed is accepted.
