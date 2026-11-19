#!/usr/bin/env python3
"""Audit YouTube video metadata for the child-safety review workflow.

This tool ONLY fetches official Data API metadata and writes a separate CSV.
It never changes review_status, rights_check, age_band, or the app playback gate.
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

API_URL = "https://www.googleapis.com/youtube/v3/videos"
VIDEO_ID_RE = re.compile(r"^[A-Za-z0-9_-]{11}$")
BATCH_SIZE = 50
OUTPUT_FIELDS = [
    "checked_at_utc",
    "video_id",
    "catalog_title",
    "catalog_channel",
    "subject",
    "language",
    "api_result",
    "api_title",
    "api_channel",
    "api_channel_id",
    "category_id",
    "published_at",
    "privacy_status",
    "made_for_kids",
    "self_declared_made_for_kids",
    "embeddable",
    "human_content_review",
    "human_age_suitability_review",
    "human_rights_review",
    "approval_decision",
]


class YouTubeApiError(RuntimeError):
    """A sanitized YouTube Data API request error."""


def load_catalog(path: Path) -> list[dict[str, str]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise YouTubeApiError(f"Could not read catalogue: {exc}") from exc

    if not isinstance(payload, dict) or not isinstance(payload.get("items"), list):
        raise YouTubeApiError("Catalogue must contain an 'items' list.")

    records: list[dict[str, str]] = []
    seen: set[str] = set()
    for raw in payload["items"]:
        if not isinstance(raw, dict):
            continue
        video_id = str(raw.get("video_id", "")).strip()
        if not VIDEO_ID_RE.fullmatch(video_id) or video_id in seen:
            continue
        seen.add(video_id)
        records.append({
            "video_id": video_id,
            "title": str(raw.get("title", "")).strip(),
            "channel": str(raw.get("channel", "")).strip(),
            "subject": str(raw.get("subject", "")).strip(),
            "language": str(raw.get("language", "")).strip(),
        })
    return records


def api_bool(value: Any, *, true_value: str, false_value: str) -> str:
    if value is True:
        return true_value
    if value is False:
        return false_value
    return "UNKNOWN"


def fetch_batch(video_ids: list[str], api_key: str, timeout: int = 30) -> dict[str, dict[str, Any]]:
    params = urlencode({
        "part": "snippet,status",
        "id": ",".join(video_ids),
        "key": api_key,
        "fields": (
            "items(id,snippet(title,channelId,channelTitle,categoryId,publishedAt),"
            "status(privacyStatus,embeddable,madeForKids,selfDeclaredMadeForKids))"
        ),
    })
    request = Request(
        f"{API_URL}?{params}",
        headers={"Accept": "application/json", "User-Agent": "ChottoPathshala-VideoAudit/1.0"},
    )
    try:
        with urlopen(request, timeout=timeout) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except HTTPError as exc:
        # Do not print the request URL: it contains the API key.
        detail = "request rejected"
        try:
            body = json.loads(exc.read().decode("utf-8"))
            detail = str(body.get("error", {}).get("message") or detail)
        except (UnicodeDecodeError, json.JSONDecodeError, AttributeError):
            pass
        raise YouTubeApiError(f"YouTube Data API HTTP {exc.code}: {detail}") from None
    except (URLError, TimeoutError) as exc:
        raise YouTubeApiError(f"YouTube Data API connection failed: {exc.reason if isinstance(exc, URLError) else 'timeout'}") from None
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise YouTubeApiError("YouTube Data API returned an invalid JSON response.") from exc

    items = payload.get("items", [])
    if not isinstance(items, list):
        raise YouTubeApiError("YouTube Data API response did not contain a valid items list.")
    result: dict[str, dict[str, Any]] = {}
    for item in items:
        if isinstance(item, dict) and isinstance(item.get("id"), str):
            result[item["id"]] = item
    return result


def build_rows(
    records: list[dict[str, str]],
    api_items: dict[str, dict[str, Any]],
    checked_at: str,
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for record in records:
        video_id = record["video_id"]
        item = api_items.get(video_id)
        row = {field: "" for field in OUTPUT_FIELDS}
        row.update({
            "checked_at_utc": checked_at,
            "video_id": video_id,
            "catalog_title": record["title"],
            "catalog_channel": record["channel"],
            "subject": record["subject"],
            "language": record["language"],
            "human_content_review": "REQUIRED",
            "human_age_suitability_review": "REQUIRED",
            "human_rights_review": "REQUIRED",
            "approval_decision": "NOT_APPROVED_BY_API_AUDIT",
        })
        if item is None:
            row["api_result"] = "NOT_RETURNED"
            row["made_for_kids"] = "UNKNOWN"
            row["self_declared_made_for_kids"] = "UNKNOWN"
            row["embeddable"] = "UNKNOWN"
            rows.append(row)
            continue

        snippet = item.get("snippet") if isinstance(item.get("snippet"), dict) else {}
        status = item.get("status") if isinstance(item.get("status"), dict) else {}
        row.update({
            "api_result": "FOUND",
            "api_title": str(snippet.get("title", "")),
            "api_channel": str(snippet.get("channelTitle", "")),
            "api_channel_id": str(snippet.get("channelId", "")),
            "category_id": str(snippet.get("categoryId", "")),
            "published_at": str(snippet.get("publishedAt", "")),
            "privacy_status": str(status.get("privacyStatus", "UNKNOWN")),
            "made_for_kids": api_bool(
                status.get("madeForKids"),
                true_value="CONFIRMED_MADE_FOR_KIDS",
                false_value="NOT_MADE_FOR_KIDS",
            ),
            "self_declared_made_for_kids": api_bool(
                status.get("selfDeclaredMadeForKids"),
                true_value="TRUE",
                false_value="FALSE",
            ),
            "embeddable": api_bool(
                status.get("embeddable"),
                true_value="CONFIRMED_EMBEDDABLE",
                false_value="NOT_EMBEDDABLE",
            ),
        })
        rows.append(row)
    return rows


def write_report(path: Path, rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=OUTPUT_FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Fetch official YouTube Made for Kids and embeddability metadata without approving videos."
    )
    parser.add_argument(
        "--catalog",
        type=Path,
        default=Path("assets/videos/video_catalog.json"),
        help="Path to the app video catalogue JSON.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("build/youtube_video_api_audit.csv"),
        help="Separate CSV report path (never overwrites the approval register).",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Optional small test limit; 0 audits the full catalogue.",
    )
    parser.add_argument(
        "--pause",
        type=float,
        default=0.1,
        help="Pause in seconds between API batches (default: 0.1).",
    )
    args = parser.parse_args()

    api_key = os.environ.get("YOUTUBE_API_KEY", "").strip()
    if not api_key:
        print("ERROR: Set YOUTUBE_API_KEY in the environment; never commit the key.", file=sys.stderr)
        return 2
    if args.limit < 0 or args.pause < 0:
        print("ERROR: --limit and --pause cannot be negative.", file=sys.stderr)
        return 2

    try:
        records = load_catalog(args.catalog)
        if args.limit:
            records = records[:args.limit]
        if not records:
            raise YouTubeApiError("No valid video IDs were found in the catalogue.")

        api_items: dict[str, dict[str, Any]] = {}
        batches = [records[i:i + BATCH_SIZE] for i in range(0, len(records), BATCH_SIZE)]
        for index, batch in enumerate(batches, start=1):
            ids = [record["video_id"] for record in batch]
            api_items.update(fetch_batch(ids, api_key))
            print(f"Checked API batch {index}/{len(batches)} ({len(ids)} IDs).")
            if index < len(batches) and args.pause:
                time.sleep(args.pause)

        checked_at = datetime.now(timezone.utc).isoformat(timespec="seconds")
        rows = build_rows(records, api_items, checked_at)
        write_report(args.output, rows)

    except YouTubeApiError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except OSError as exc:
        print(f"ERROR: Could not write report: {exc}", file=sys.stderr)
        return 1

    found = sum(row["api_result"] == "FOUND" for row in rows)
    mfk = sum(row["made_for_kids"] == "CONFIRMED_MADE_FOR_KIDS" for row in rows)
    embeddable = sum(row["embeddable"] == "CONFIRMED_EMBEDDABLE" for row in rows)
    not_embeddable = sum(row["embeddable"] == "NOT_EMBEDDABLE" for row in rows)
    print(f"Report written: {args.output}")
    print(f"Catalogue IDs: {len(rows)} | API returned: {found} | Not returned: {len(rows) - found}")
    print(f"Made for Kids confirmed: {mfk} | Embeddable confirmed: {embeddable} | Not embeddable: {not_embeddable}")
    print("IMPORTANT: This is metadata only. Human content, age-suitability and rights reviews remain required.")
    print("No catalogue fields, approval statuses, or playback build flags were changed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
