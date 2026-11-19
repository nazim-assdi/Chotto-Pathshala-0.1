# Chotto Pathshala — YouTube public metadata preflight

Date: 19 November 2026  
Branch: feature/advanced-learning

## No API key required for this preflight

The repository audit now uses YouTube's public oEmbed endpoint. It does not use YouTube Data API v3, a Google Cloud project, OAuth, or an API key.

It checks public title/channel metadata for each video ID and compares those values with the catalogue. The report is written to:

\`build/youtube_video_public_audit.csv\`

The report is read-only and never changes \`assets/videos/video_catalog.json\`, \`docs/VIDEO_CONTENT_REVIEW.csv\`, review decisions, rights fields, or app build flags.

## What the result means

- \`FOUND\`: YouTube returned public oEmbed metadata (title/channel/thumbnail).
- \`HTTP_401\`, \`HTTP_403\`, \`HTTP_404\`: YouTube did not return oEmbed metadata with that response. The audit does not infer the exact reason; the video may be restricted, unavailable, private, deleted, or have other access limitations.
- \`NETWORK_ERROR\`, \`INVALID_RESPONSE\`: the request could not be reliably checked.
- \`title_match\` / \`channel_match\`: normalized comparison against the catalogue. A mismatch is a manual-review flag, not proof of misuse.

**Important limitations:** oEmbed does not return an authoritative Made for Kids flag, copyright/license permission, complete video content, age suitability, or a definitive \`status.embeddable\` value. An oEmbed response is not proof that an IFrame player will successfully play in the app. All of those fields remain \`NOT_CHECKED\` unless independently verified.

For context, YouTube's embedding guidance explains that owners can turn embedding off and that child-oriented apps embedding YouTube content must self-designate using YouTube's tools:
- https://support.google.com/youtube/answer/171780
- https://developers.google.com/youtube/iframe_api_reference

## Run locally (no secret)

Windows PowerShell, macOS or Linux with Python 3.10+:

\`\`\`bash
python tool/audit_youtube_videos.py --limit 25
python tool/audit_youtube_videos.py
\`\`\`

The default pause is 0.2 seconds per video. The complete 1,638-record catalogue can take several minutes. The command writes a separate CSV under \`build/\`; it does not edit the review register.

## GitHub Actions

The workflow runs automatically when the audit script, its tests, the catalogue or this document changes on \`feature/advanced-learning\`. It can also be run manually from Actions → "YouTube public video metadata audit (no API key)". Set \`limit=0\` for the entire catalogue.

The workflow uploads \`youtube-public-video-audit\` as an artifact. No GitHub secret is needed.

## What is still required before a child-facing video can be approved

A human reviewer must watch the complete video, including linked/outro material, assess the content and teaching accuracy, assign a real age band, and document usage rights/permission. The review register also requires authoritative confirmation of YouTube's Made for Kids status and embedding eligibility. The keyless oEmbed preflight cannot supply those two authoritative fields.

Therefore:
- Do not translate \`FOUND\` into \`APPROVED\`.
- Do not set \`made_for_kids_status\` or \`embedding_status\` from oEmbed.
- Do not set \`rights_check\` from channel or title metadata.
- Keep any item with missing/unknown evidence in \`PENDING_REVIEW\`.
- Keep the app-level \`YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED\` build gate false until the owner completes the required Google child-directed API Client notification and privacy setup.

This is a public-metadata triage tool, not an automated approval or child-safety certification.
