# 2,000-record video library architecture

## What this release contains

The video section is a searchable, category-based catalogue with capacity for up to 2,000 unique entries. The Flutter parser accepts up to 2,000 records and renders them lazily, 20 at a time. It includes local bookmarks, dynamic subject filters generated from every subject in the catalogue, with live item counts, language filters with live counts, review-status filters (pending/approved/rejected), search by title/channel/video ID/subject/language, and a localized per-record review indicator. A clear-filters action resets every filter together.

The current manifest contains **1,638 unique video IDs with real titles and channel metadata**: 25 legacy records, 975 candidates from the first collection, and 638 newly collected candidates. The subject counts are English (200), Bangla (200), mathematics (100), science/nature (150), Islamic learning (587) and Arabic (401). All 1,638 are marked `PENDING_REVIEW`; none is approved or playable. Metadata collection confirms that the IDs and titles were present in public channel listings, but it does not verify full video content, current availability, child suitability, Made for Kids status, advertising, privacy behaviour or usage rights. This is an expanded candidate catalogue, not a safety-approved curriculum.

## Adding a video

Add one record to assets/videos/video_catalog.json with these fields:

- video_id: stable 11-character YouTube video ID
- title, channel, subject, language
- review_status, age_band, made_for_kids_status, rights_check

Public channel listings may be used only to discover candidate video IDs and metadata. Each discovered video is added as PENDING_REVIEW, never as approved. Each exact video ID must have a completed individual review record in docs/VIDEO_CONTENT_REVIEW.csv.

## Approval gate

A record can only be considered eligible for a later playback integration when its review status is APPROVED, an intended age band is recorded, the individual video's Made for Kids status is confirmed, and rights are confirmed. A qualified reviewer must also document the full-video review, advertising/recommendation behaviour, external navigation and privacy observations in the review register.

This release does not bundle a video player or network permission. The card tap deliberately shows a status-aware review/playback notice, including a separate message for approved records because player integration is not enabled in this release. The YouTube embedded-player API does not provide a supported way to completely remove related videos; rel=0 only limits related videos to the same channel. Ads and YouTube-side processing are outside this app's control. Do not enable an embedded player in a child-directed release until the exact integration is re-assessed against the current Google Play Families policy, YouTube API terms, privacy disclosures and Data Safety answers.

## Data integrity

- Video IDs must match the 11-character YouTube ID pattern.
- Duplicate IDs and incomplete records are ignored by the loader.
- Title, channel, subject, language and review metadata are trimmed before filtering; search also matches a video's exact YouTube ID.
- The loader caps catalogue input at 2,000 unique valid entries.
- Bookmarks are kept locally using SharedPreferences.
- The collector stores metadata only; it does not download media.
- Automatic discovery never changes a review status to APPROVED.
- The app still has 0 approved/playable videos.
