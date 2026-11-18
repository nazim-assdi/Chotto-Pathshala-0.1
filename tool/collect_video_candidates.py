#!/usr/bin/env python3
"""Collect real public video metadata from the review-register channel candidates.

This does not download media and never approves a video. Every new record is
PENDING_REVIEW until a human has watched and checked it individually.
"""
from __future__ import annotations

import csv
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "assets/videos/video_catalog.json"
REVIEW_PATH = ROOT / "docs/VIDEO_CONTENT_REVIEW.csv"
VIDEO_ID = re.compile(r"^[A-Za-z0-9_-]{11}$")
MAX_ITEMS = 1000
PER_CHANNEL_LIMIT = 35
FIELDS = [
    "record_type", "video_id_or_source_id", "title_or_source_name",
    "channel_name", "subject", "language", "review_status", "reviewer",
    "review_date", "age_band", "made_for_kids_status", "rights_check",
    "review_notes",
]

def channel_url(source_id: str) -> str:
    if source_id.startswith("UC") and len(source_id) == 24:
        return f"https://www.youtube.com/channel/{source_id}/videos"
    return f"https://www.youtube.com/@{source_id}/videos"

def load_review_rows():
    with REVIEW_PATH.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def main() -> int:
    catalog = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    items = catalog.get("items", [])
    known = {x.get("video_id") for x in items}
    rows = load_review_rows()
    sources = [
        row for row in rows
        if row.get("record_type") == "feed_source_candidate"
        and row.get("review_status") == "SOURCE_ONLY_NOT_APPROVED"
    ]
    if not sources:
        print("No channel candidates found in the review register.")
        return 1

    added = 0
    failed = []
    for index, source in enumerate(sources, start=1):
        source_id = (source.get("video_id_or_source_id") or "").strip()
        source_name = (source.get("title_or_source_name") or source_id).strip()
        print(f"[{index}/{len(sources)}] Reading public metadata: {source_name}", flush=True)
        command = [
            sys.executable, "-m", "yt_dlp",
            "--ignore-errors", "--flat-playlist", "--dump-single-json",
            "--playlist-end", str(PER_CHANNEL_LIMIT),
            "--socket-timeout", "15", "--retries", "1", "--extractor-retries", "1",
            "--no-warnings", "--quiet",
            channel_url(source_id),
        ]
        try:
            result = subprocess.run(
                command, check=True, capture_output=True, text=True, timeout=50
            )
            payload = json.loads(result.stdout)
        except Exception as exc:
            failed.append(f"{source_name}: {type(exc).__name__}")
            continue

        entries = payload.get("entries") or []
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            video_id = str(entry.get("id") or "")
            title = str(entry.get("title") or "").strip()
            if not VIDEO_ID.fullmatch(video_id) or video_id in known or not title:
                continue
            if title.startswith(("[Deleted video]", "[Private video]", "Private video")):
                continue
            if entry.get("is_live") or entry.get("live_status") in {"is_live", "is_upcoming"}:
                continue
            duration = entry.get("duration")
            if duration is not None and (duration < 30 or duration > 3600):
                continue

            channel = str(entry.get("channel") or entry.get("uploader") or source_name).strip()
            subject = source.get("subject") or "সাধারণ জ্ঞান"
            language = source.get("language") or "English"
            item = {
                "video_id": video_id,
                "title": title,
                "channel": channel,
                "subject": subject,
                "language": language,
                "review_status": "PENDING_REVIEW",
                "age_band": "",
                "made_for_kids_status": "NOT_CHECKED",
                "rights_check": "",
            }
            items.append(item)
            known.add(video_id)
            rows.append({
                "record_type": "collected_video_candidate",
                "video_id_or_source_id": video_id,
                "title_or_source_name": title,
                "channel_name": channel,
                "subject": subject,
                "language": language,
                "review_status": "PENDING_REVIEW",
                "reviewer": "",
                "review_date": "",
                "age_band": "",
                "made_for_kids_status": "NOT_CHECKED",
                "rights_check": "",
                "review_notes": f"Metadata collected from source candidate {source_name}; watch full video and verify individually before approval",
            })
            added += 1
            if len(items) >= MAX_ITEMS:
                break
        if len(items) >= MAX_ITEMS:
            break

    catalog["schema_version"] = 1
    catalog["target_count"] = MAX_ITEMS
    catalog["page_size"] = 20
    catalog["items"] = items[:MAX_ITEMS]
    CATALOG_PATH.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    with REVIEW_PATH.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)

    print(f"Unique real video records in catalogue: {len(catalog['items'])}")
    print(f"New metadata candidates added: {added}")
    print(f"Still awaiting individual human review: {sum(x.get('review_status') != 'APPROVED' for x in catalog['items'])}")
    if failed:
        print("Channel sources that could not be read:")
        for message in failed:
            print(f" - {message}")
    return 0 if len(catalog["items"]) >= MAX_ITEMS else 2

if __name__ == "__main__":
    raise SystemExit(main())
