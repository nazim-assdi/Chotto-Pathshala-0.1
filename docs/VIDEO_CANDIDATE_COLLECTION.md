# Video candidate catalogue — current collection and review policy

Audit date: 21 November 2026  
Branch: `feature/advanced-learning`

The bundled catalogue contains **1,638 unique YouTube video IDs** with titles/channel metadata: English (200), Bangla (200), mathematics (100), science/nature (150), Islamic learning (587), and Arabic (401). All 1,638 bundled records remain `PENDING_REVIEW`; none is approved or playable. The catalogue loader can hold up to 2,000 combined records, including candidates manually added on the device.

## Restored discovery workflow

The previous 36 configured channel/feed sources have been restored as a manual discovery feature. The user taps Refresh to request the public YouTube Atom feed from each configured source; the app does not contact feeds at startup. A successful feed may provide up to 15 recent entries. The result varies by source; older username-based feeds may not respond. Web preview may be affected by CORS restrictions.

The Add YouTube URL action accepts a YouTube URL or 11-character video ID and lets the user set the title, subject, language and format. Feed and user-added candidates are stored locally in SharedPreferences. They can be removed from the local queue. No API key is required for the public Atom-feed lookup.

## Candidate-only guarantee

Feed discovery and manual import are never approvals. The loader normalizes locally stored candidate records back to:
- `review_status=PENDING_REVIEW`
- empty `age_band`
- `made_for_kids_status=NOT_CHECKED`
- empty `rights_check`
- `embedding_status=NOT_CHECKED`

They do not become playable simply because a title, channel, feed, user or URL was supplied. The default app-level `YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED` build flag remains false. No auto-play or hover playback is implemented.

## Required review before any playback

For every individual video ID, an adult reviewer must:
1. Watch the full video, including its opening, ending, captions, and external prompts, and record whether the complete content is appropriate for the actual target age group.
2. Query the official YouTube Data API `videos.list` endpoint and record the current `status.madeForKids` value; re-check it when required by current API rules.
3. Confirm through authoritative YouTube evidence that embedding is allowed and verify the applicable usage rights.
4. Record reviewer, review date, age band, Made for Kids status, rights decision, embedding evidence and notes in `docs/VIDEO_CONTENT_REVIEW.csv` and keep the catalogue record in sync.
5. Have the app owner complete any required Google notification for a child-directed API client and the privacy/Data Safety assessment before shipping an embedded player.

No item may be marked `APPROVED` based only on a title, channel, thumbnail, feed entry or playlist. The application gate additionally requires `CONFIRMED_MADE_FOR_KIDS`, a non-empty age band, `rights_check=CONFIRMED`, and `embedding_status=CONFIRMED_EMBEDDABLE`. Unknown values are not approvals. A child must explicitly press the embedded player's native Play control if playback is ever enabled after compliance review.

## Policy distinction

Use the official public Atom feed endpoint only for the limited candidate discovery described here; do not scrape YouTube pages or use feed results as a substitute for official API checks. The feed is not a review API, content analysis API, Made for Kids check, licence grant, or playback permission.
