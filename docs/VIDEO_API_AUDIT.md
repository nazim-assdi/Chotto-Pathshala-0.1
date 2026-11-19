# YouTube video metadata audit

This is a **metadata pre-check**, not a content moderation tool and not an approval action.

## What it checks

`tool/audit_youtube_videos.py` reads the app catalogue and calls the official YouTube Data API v3 `videos.list` endpoint in batches of up to 50 video IDs. It writes a separate report to `build/youtube_video_api_audit.csv` and records:

- whether the ID was returned by the API
- current YouTube title, channel, category, publication date and privacy status when returned
- YouTube's `status.madeForKids` and `status.embeddable` values
- whether human review is still required for content, age suitability and rights

The report does **not** update `assets/videos/video_catalog.json` or `docs/VIDEO_CONTENT_REVIEW.csv`. It never changes `review_status`, `rights_check`, `age_band` or the child-directed build gate. `NOT_RETURNED` means the API did not return that ID; it does not prove why the video was unavailable.

## One-time setup

1. Open Google Cloud Console: https://console.cloud.google.com/
2. Select or create a project and enable **YouTube Data API v3**.
3. Create an API key. Restrict it to the YouTube Data API and keep it private.
4. Set the key only in your local terminal environment. Never paste it into source code, commits, screenshots, issues or chat.

PowerShell (Windows):

```powershell
$env:YOUTUBE_API_KEY = "YOUR_API_KEY"
```

macOS / Linux:

```bash
export YOUTUBE_API_KEY="YOUR_API_KEY"
```

## Run the audit

Start with a small sample:

```bash
python tool/audit_youtube_videos.py --limit 25
```

Then check the complete catalogue:

```bash
python tool/audit_youtube_videos.py
```

The script writes the report under `build/`, which is ignored by Git. It makes approximately 33 one-unit `videos.list` requests for the current 1,638 unique candidate IDs. YouTube's Made for Kids guide documents the `videos.list` method and the daily quota; the video resource documents the `status.madeForKids` and `status.embeddable` fields.

## Import metadata into the human review register

After generating the API report, preview the register update:

```bash
python tool/apply_youtube_audit.py
```

The default mode is preview-only. To write the metadata into `docs/VIDEO_CONTENT_REVIEW.csv`:

```bash
python tool/apply_youtube_audit.py --apply
```

The importer creates a timestamped backup before writing. It updates only the YouTube metadata fields and adds `youtube_api_checked_at`. It does not change `review_status`, reviewer, review date, age band or rights review. Unknown or unreturned API data resets the two technical metadata fields to `NOT_CHECKED` (fail closed). Channel/feed source rows are never imported.

## How to interpret the report

- `CONFIRMED_MADE_FOR_KIDS`: YouTube currently reports the video as Made for Kids.
- `NOT_MADE_FOR_KIDS`: YouTube currently reports false; do not relabel this as child-directed.
- `UNKNOWN`: the field was not present as a boolean in the response.
- `CONFIRMED_EMBEDDABLE`: YouTube currently reports the video as embeddable.
- `NOT_EMBEDDABLE`: YouTube reports that it cannot be embedded.
- `NOT_RETURNED`: the requested ID was not included in the API response.

These values can change and are not a substitute for playback testing or the individual review register. In particular, YouTube's API does not establish that the full video is suitable for a particular child age, that its teaching is accurate, or that the app has permission to use it.

## Required human review before approval

A reviewer must watch the complete video, check its content and linked/outro material, assign an age band, verify the right to use/embed it, record reviewer and date in `docs/VIDEO_CONTENT_REVIEW.csv`, and resolve every failed or unknown field. Only then can a record be considered for the catalogue's approval criteria. A YouTube Made for Kids flag alone is never enough.

The app-level `YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED` gate is independent and must remain false until the app owner completes the required child-directed API Client notification and privacy setup with Google. Running this audit does not complete that setup and does not enable playback.
