# Expanded real video candidate collection

The collector reads only channel sources already listed in the video review register. It uses yt-dlp in flat-playlist metadata mode; it does not download video or audio files. The successful expanded collection run grew the catalogue to 1,638 unique records (25 legacy entries, 975 candidates from the first collection, and 638 newly collected candidates).

- Up to 60 public video metadata entries are examined per channel source.
- Only unique, valid 11-character YouTube video IDs with a title are accepted.
- Deleted/private entries, live/upcoming streams, clips shorter than 30 seconds and videos longer than 60 minutes are skipped.
- The catalogue is capped at 2,000 unique entries.
- Every collected entry is marked `PENDING_REVIEW`; no channel or video is auto-approved.
- Current catalogue distribution: English 200, Bangla 200, mathematics 100, science/nature 150, Islamic learning 587 and Arabic 401. The expanded collector now prioritises the four underrepresented learning subjects.
- The script records the originating channel, title, subject and language in `docs/VIDEO_CONTENT_REVIEW.csv`.

A successful collection run confirms 1,638 unique video IDs and metadata records, not 1,638 child-safe videos. A human reviewer must watch each complete video and confirm age suitability, Made for Kids status, rights, advertising, external navigation and privacy behaviour before any playback integration is enabled.

Run from GitHub Actions → **Collect 1,000 real video candidates**. The workflow commits the resulting catalogue and review register to `feature/advanced-learning`.
