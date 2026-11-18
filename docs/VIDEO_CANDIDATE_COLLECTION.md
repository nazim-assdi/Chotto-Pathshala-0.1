# Real video candidate collection

The collector reads only channel sources already listed in the video review register. It uses yt-dlp in flat-playlist metadata mode; it does not download video or audio files.

- Up to 100 public video metadata entries are examined per channel source.
- Only unique, valid 11-character YouTube video IDs with a title are accepted.
- Deleted/private entries, live/upcoming streams, clips shorter than 30 seconds and videos longer than 60 minutes are skipped.
- The catalogue is capped at 1,000 unique entries.
- Every collected entry is marked `PENDING_REVIEW`; no channel or video is auto-approved.
- The script records the originating channel, title, subject and language in `docs/VIDEO_CONTENT_REVIEW.csv`.

A successful collection run does not mean 1,000 child-safe videos have been approved. A human reviewer must watch each complete video and confirm age suitability, Made for Kids status, rights, advertising, external navigation and privacy behaviour before any playback integration is enabled.

Run from GitHub Actions → **Collect 1,000 real video candidates**. The workflow commits the resulting catalogue and review register to `feature/advanced-learning`.
