# Video candidate catalogue — historical collection record

Audit date: 19 November 2026  
Branch: `feature/advanced-learning`

The current catalogue contains 1,638 unique YouTube video IDs. The records are discovery candidates only; **all 1,638 are still `PENDING_REVIEW` and none is approved or playable**. The catalogue is capped at 2,000 entries and currently groups candidates into English (200), Bangla (200), mathematics (100), science and nature (150), Islamic learning (587), and Arabic (401).

The historical candidate set was assembled from public channel listings without downloading media. This is not a content-safety review, a Made for Kids status check, proof that embedding is enabled, or evidence of copyright permission. Titles, channel names, descriptions, and candidate IDs must not be treated as sufficient grounds to make a video accessible to children.

## Collection automation retired

The former GitHub Actions workflow and its `yt-dlp` channel-page collector have been removed. Do not run automated scraping or channel-feed harvesting again. YouTube's current developer policies prohibit scraping YouTube applications or Google applications. For any future YouTube-based catalogue work, the app owner must use the official YouTube Data API, keep API credentials out of the client and repository, and follow the current API Terms and Developer Policies.

## Required review before any playback

For every individual video ID, an adult reviewer must:
1. Watch the full video, including its opening, ending, captions, and any external prompts, and record whether the complete content is appropriate for the actual target age group.
2. Query the official YouTube Data API `videos.list` endpoint and record the current `status.madeForKids` value; re-check it when required by the current API rules.
3. Confirm through the official API that embedding is allowed, record `embedding_status=CONFIRMED_EMBEDDABLE`, and verify that use of the video in this app is lawful and consistent with the creator's rights and YouTube terms.
4. Record reviewer, review date, age band, Made for Kids status, rights decision, and notes in `docs/VIDEO_CONTENT_REVIEW.csv` and keep the catalogue record in sync.
5. Have the app owner complete any required Google notification for a child-directed API client and the privacy/Data Safety assessment before shipping an embedded player.

No item may be marked `APPROVED` based only on its title, channel, thumbnail, playlist membership, or a channel's general focus. The application approval gate also requires `CONFIRMED_MADE_FOR_KIDS`, a non-empty age band, `rights_check=CONFIRMED`, and `embedding_status=CONFIRMED_EMBEDDABLE`; absent/unknown values are not approvals. Autoplay and hover-triggered playback remain off. A child must explicitly press the embedded player's native Play control if YouTube playback is ever enabled after the full compliance review.
