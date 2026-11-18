# 1,000-video library architecture

## What this release contains

The video section has been restored as a searchable, category-based catalogue. It is designed for up to 1,000 unique entries and renders records lazily, with a target page size of 20. It includes local bookmarks, category filters, search by title/channel/subject/language, and a review-status indicator.

The current manifest now contains **1,000 unique video IDs with real titles and channel metadata**: 25 legacy records plus 975 entries collected from public channel video listings. All 1,000 are marked PENDING_REVIEW; none is approved or playable. Metadata collection confirms that the listed video IDs were present in the source channel listings, but it does not verify the full video content, current availability, child suitability, Made for Kids status, advertising, privacy behaviour or usage rights. The current subject mix is heavily weighted toward Islamic learning (587) and Arabic (401), with English (5), Bangla (4), science/nature (1) and mathematics (2). This is a candidate catalogue, not a balanced or safety-approved curriculum.

## Adding a video

Add one record to assets/videos/video_catalog.json with these fields:

- video_id: stable 11-character YouTube video ID
- title, channel, subject, language
- review_status, age_band, made_for_kids_status, rights_check

Public channel listings may be used only to discover candidate video IDs and metadata. Each discovered video is added as PENDING_REVIEW, never as approved. Each exact video ID must have a completed individual review record in docs/VIDEO_CONTENT_REVIEW.csv.

## Approval gate

A record can only be considered eligible for a later playback integration when its review status is APPROVED, an intended age band is recorded, the individual video's Made for Kids status is confirmed, and rights are confirmed. A qualified reviewer must also document the full-video review, advertising/recommendation behaviour, external navigation and privacy observations in the review register.

This release does not bundle a video player or network permission. The card tap deliberately shows a review notice. The YouTube embedded-player API does not provide a supported way to completely remove related videos; rel=0 only limits related videos to the same channel. Ads and YouTube-side processing are outside this app's control. Do not enable an embedded player in a child-directed release until the exact integration is re-assessed against the current Google Play Families policy, YouTube API terms, privacy disclosures and Data Safety answers.

## Data integrity

- Video IDs must match the 11-character YouTube ID pattern.
- Duplicate IDs and incomplete records are ignored by the loader.
- The loader caps catalogue input at 1,000 unique valid entries.
- Bookmarks are kept locally using SharedPreferences.
- The collector stores metadata only; it does not download media.
- Automatic discovery never changes a review status to APPROVED.
- The app still has 0 approved/playable videos.
