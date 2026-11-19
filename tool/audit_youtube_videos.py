#!/usr/bin/env python3
"""Keyless, read-only public metadata preflight for the video review workflow.

Uses YouTube's public oEmbed endpoint. It does not use the YouTube Data API,
does not require an API key, and never changes approval or playback fields.
oEmbed cannot establish Made for Kids status, legal rights, full-video safety,
or authoritative embeddability.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

OEMBED_URL = "https://www.youtube.com/oembed"
VIDEO_ID_RE = re.compile(r"^[A-Za-z0-9_-]{11}$")
OUTPUT_FIELDS = [
    "checked_at_utc", "video_id", "catalog_title", "catalog_channel",
    "subject", "language", "oembed_result", "oembed_http_status",
    "oembed_title", "oembed_channel", "oembed_channel_url", "thumbnail_url",
    "title_match", "channel_match", "made_for_kids_status",
    "embedding_status", "rights_check", "human_content_review",
    "human_age_suitability_review", "human_rights_review",
    "approval_decision", "review_note",
]


class AuditError(RuntimeError):
    """A sanitized public metadata audit error."""


def load_catalog(path: Path) -> list[dict[str, str]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise AuditError(f"Could not read catalogue: {exc}") from exc
    if not isinstance(payload, dict) or not isinstance(payload.get("items"), list):
        raise AuditError("Catalogue must contain an 'items' list.")
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


def normalized_match(expected: str, actual: str) -> str:
    """Compare public metadata without treating a mismatch as a rejection."""
    if not expected.strip() or not actual.strip():
        return "UNKNOWN"
    normalize = lambda value: re.sub(r"[\W_]+", "", value.casefold())
    return "MATCH" if normalize(expected) == normalize(actual) else "DIFFERS"


def fetch_oembed(video_id: str, timeout: int = 20) -> tuple[dict[str, Any] | None, str, str]:
    """Fetch public title/channel metadata; return (payload, result, HTTP status)."""
    if not VIDEO_ID_RE.fullmatch(video_id):
        return None, "INVALID_VIDEO_ID", ""
    params = urlencode({
        "url": f"https://www.youtube.com/watch?v={video_id}",
        "format": "json",
    })
    request = Request(
        f"{OEMBED_URL}?{params}",
        headers={"Accept": "application/json", "User-Agent": "ChottoPathshala-PublicVideoAudit/1.0"},
    )
    for attempt in range(3):
        try:
            with urlopen(request, timeout=timeout) as response:
                http_status = str(getattr(response, "status", 200))
                payload = json.loads(response.read().decode("utf-8"))
            if not isinstance(payload, dict) or payload.get("provider_name") != "YouTube":
                return None, "INVALID_RESPONSE", http_status
            return payload, "FOUND", http_status
        except HTTPError as exc:
            if exc.code in {429, 500, 502, 503, 504} and attempt < 2:
                time.sleep(2 ** attempt)
                continue
            return None, f"HTTP_{exc.code}", str(exc.code)
        except (URLError, TimeoutError):
            if attempt < 2:
                time.sleep(2 ** attempt)
                continue
            return None, "NETWORK_ERROR", ""
        except (UnicodeDecodeError, json.JSONDecodeError):
            return None, "INVALID_RESPONSE", ""
    return None, "REQUEST_FAILED", ""


def build_rows(
    records: list[dict[str, str]],
    responses: dict[str, tuple[dict[str, Any] | None, str, str]],
    checked_at: str,
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for record in records:
        video_id = record["video_id"]
        payload, result, http_status = responses.get(video_id, (None, "NOT_CHECKED", ""))
        payload = payload if isinstance(payload, dict) else {}
        actual_title = str(payload.get("title", "")).strip()
        actual_channel = str(payload.get("author_name", "")).strip()
        row = {field: "" for field in OUTPUT_FIELDS}
        row.update({
            "checked_at_utc": checked_at,
            "video_id": video_id,
            "catalog_title": record["title"],
            "catalog_channel": record["channel"],
            "subject": record["subject"],
            "language": record["language"],
            "oembed_result": result,
            "oembed_http_status": http_status,
            "oembed_title": actual_title,
            "oembed_channel": actual_channel,
            "oembed_channel_url": str(payload.get("author_url", "")),
            "thumbnail_url": str(payload.get("thumbnail_url", "")),
            "title_match": normalized_match(record["title"], actual_title) if result == "FOUND" else "UNKNOWN",
            "channel_match": normalized_match(record["channel"], actual_channel) if result == "FOUND" else "UNKNOWN",
            "made_for_kids_status": "NOT_CHECKED",
            "embedding_status": "NOT_CHECKED",
            "rights_check": "NOT_CHECKED",
            "human_content_review": "REQUIRED",
            "human_age_suitability_review": "REQUIRED",
            "human_rights_review": "REQUIRED",
            "approval_decision": "NOT_APPROVED_BY_PUBLIC_METADATA_AUDIT",
            "review_note": (
                "Public oEmbed metadata only; full video, age suitability, Made for Kids, "
                "embedding permission and usage rights remain unverified."
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
        description="Check public YouTube title/channel metadata without an API key; never approves videos."
    )
    parser.add_argument("--catalog", type=Path, default=Path("assets/videos/video_catalog.json"))
    parser.add_argument("--output", type=Path, default=Path("build/youtube_video_public_audit.csv"))
    parser.add_argument("--limit", type=int, default=0, help="0 audits the full catalogue.")
    parser.add_argument("--pause", type=float, default=0.2, help="Pause between requests (default: 0.2 seconds).")
    args = parser.parse_args()
    if args.limit < 0 or args.pause < 0:
        print("ERROR: --limit and --pause cannot be negative.", file=sys.stderr)
        return 2
    try:
        records = load_catalog(args.catalog)
        if args.limit:
            records = records[:args.limit]
        if not records:
            raise AuditError("No valid video IDs were found in the catalogue.")
        responses: dict[str, tuple[dict[str, Any] | None, str, str]] = {}
        for index, record in enumerate(records, start=1):
            responses[record["video_id"]] = fetch_oembed(record["video_id"])
            if index % 25 == 0 or index == len(records):
                print(f"Checked public metadata {index}/{len(records)} videos.")
            if index < len(records) and args.pause:
                time.sleep(args.pause)
        checked_at = datetime.now(timezone.utc).isoformat(timespec="seconds")
        rows = build_rows(records, responses, checked_at)
        write_report(args.output, rows)
    except AuditError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except OSError as exc:
        print(f"ERROR: Could not write report: {exc}", file=sys.stderr)
        return 1
    found = sum(row["oembed_result"] == "FOUND" for row in rows)
    title_differs = sum(row["title_match"] == "DIFFERS" for row in rows)
    channel_differs = sum(row["channel_match"] == "DIFFERS" for row in rows)
    print(f"Report written: {args.output}")
    print(f"Catalogue IDs: {len(rows)} | Public metadata found: {found} | Other responses: {len(rows) - found}")
    print(f"Title mismatches: {title_differs} | Channel mismatches: {channel_differs}")
    print("Made for Kids: NOT_CHECKED | Embedding permission: NOT_CHECKED | Usage rights: NOT_CHECKED")
    print("IMPORTANT: This is a public metadata preflight, not a child-safety or approval check.")
    print("No catalogue fields, approval statuses, review records, or playback build flags were changed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
