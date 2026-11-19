#!/usr/bin/env python3
"""Safely merge YouTube API metadata into the human review register.

This utility never changes review_status, reviewer, review_date, age_band or
rights_check. It requires --apply before writing and makes a backup first.
"""
from __future__ import annotations

import argparse
import csv
import os
import re
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REVIEWABLE_TYPES = {"bundled_video", "collected_video_candidate"}
VIDEO_ID_RE = re.compile(r"^[A-Za-z0-9_-]{11}$")
MADE_FOR_KIDS_VALUES = {"CONFIRMED_MADE_FOR_KIDS", "NOT_MADE_FOR_KIDS"}
EMBEDDING_VALUES = {"CONFIRMED_EMBEDDABLE", "NOT_EMBEDDABLE"}
REQUIRED_AUDIT_FIELDS = {
    "video_id",
    "api_result",
    "made_for_kids",
    "embeddable",
    "checked_at_utc",
}
PROTECTED_FIELDS = {
    "review_status",
    "reviewer",
    "review_date",
    "age_band",
    "rights_check",
}


class MergeError(RuntimeError):
    """Invalid or unsafe merge input."""


def read_csv(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    try:
        with path.open("r", newline="", encoding="utf-8-sig") as handle:
            reader = csv.DictReader(handle)
            if not reader.fieldnames:
                raise MergeError(f"CSV has no header: {path}")
            return list(reader.fieldnames), list(reader)
    except OSError as exc:
        raise MergeError(f"Cannot read {path}: {exc}") from exc


def build_merge(
    register_fields: list[str],
    register_rows: list[dict[str, str]],
    audit_fields: list[str],
    audit_rows: list[dict[str, str]],
) -> tuple[list[str], list[dict[str, str]], dict[str, int]]:
    missing = REQUIRED_AUDIT_FIELDS - set(audit_fields)
    if missing:
        raise MergeError("Audit report is missing required columns: " + ", ".join(sorted(missing)))

    output_fields = list(register_fields)
    for name in ("youtube_api_checked_at",):
        if name not in output_fields:
            output_fields.append(name)

    targets: dict[str, int] = {}
    for index, row in enumerate(register_rows):
        if row.get("record_type", "") not in REVIEWABLE_TYPES:
            continue
        video_id = (row.get("video_id_or_source_id") or "").strip()
        if not VIDEO_ID_RE.fullmatch(video_id):
            continue
        if video_id in targets:
            raise MergeError(f"Duplicate review-register video ID: {video_id}")
        targets[video_id] = index

    reports: dict[str, dict[str, str]] = {}
    for row in audit_rows:
        video_id = (row.get("video_id") or "").strip()
        if not VIDEO_ID_RE.fullmatch(video_id):
            raise MergeError(f"Invalid video ID in audit report: {video_id!r}")
        if video_id in reports:
            raise MergeError(f"Duplicate video ID in audit report: {video_id}")
        reports[video_id] = row

    merged = [dict(row) for row in register_rows]
    for row in merged:
        for field in output_fields:
            row.setdefault(field, "")

    updated = 0
    not_returned = 0
    not_in_register = 0
    for video_id, report in reports.items():
        index = targets.get(video_id)
        if index is None:
            not_in_register += 1
            continue
        target = merged[index]
        # Only official, explicit boolean values are imported. Missing fields
        # and IDs not returned by the API fail closed to NOT_CHECKED.
        if report.get("api_result") != "FOUND":
            target["made_for_kids_status"] = "NOT_CHECKED"
            target["embedding_status"] = "NOT_CHECKED"
            not_returned += 1
        else:
            mfk = report.get("made_for_kids", "")
            embeddable = report.get("embeddable", "")
            target["made_for_kids_status"] = (
                mfk if mfk in MADE_FOR_KIDS_VALUES else "NOT_CHECKED"
            )
            target["embedding_status"] = (
                embeddable if embeddable in EMBEDDING_VALUES else "NOT_CHECKED"
            )
        target["youtube_api_checked_at"] = report.get("checked_at_utc", "")
        updated += 1

    # Defensive invariant: this process must never alter any human decision.
    original_by_id = {
        (row.get("record_type", ""), row.get("video_id_or_source_id", "")): row
        for row in register_rows
    }
    for row in merged:
        key = (row.get("record_type", ""), row.get("video_id_or_source_id", ""))
        original = original_by_id.get(key)
        if original is None:
            continue
        for field in PROTECTED_FIELDS:
            if row.get(field, "") != original.get(field, ""):
                raise MergeError(f"Protected human-review field changed unexpectedly: {field}")

    summary = {
        "audit_rows": len(reports),
        "register_video_rows": len(targets),
        "updated": updated,
        "not_returned": not_returned,
        "not_in_register": not_in_register,
        "still_pending_or_original_review_status": sum(
            1 for row in merged
            if row.get("record_type") in REVIEWABLE_TYPES
            and row.get("review_status") == "PENDING_REVIEW"
        ),
    }
    return output_fields, merged, summary


def write_csv_atomic(path: Path, fields: list[str], rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_name: str | None = None
    try:
        with tempfile.NamedTemporaryFile(
            "w", newline="", encoding="utf-8", dir=path.parent,
            prefix=path.name + ".", suffix=".tmp", delete=False,
        ) as handle:
            temp_name = handle.name
            writer = csv.DictWriter(handle, fieldnames=fields, extrasaction="ignore")
            writer.writeheader()
            writer.writerows(rows)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp_name, path)
    except OSError:
        if temp_name and os.path.exists(temp_name):
            os.unlink(temp_name)
        raise


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Preview or safely import official YouTube metadata into the human video review register."
    )
    parser.add_argument(
        "--audit",
        type=Path,
        default=Path("build/youtube_video_api_audit.csv"),
        help="CSV produced by tool/audit_youtube_videos.py.",
    )
    parser.add_argument(
        "--register",
        type=Path,
        default=Path("docs/VIDEO_CONTENT_REVIEW.csv"),
        help="Human review register to update.",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write changes. Without this flag, only a preview is printed.",
    )
    args = parser.parse_args()

    try:
        register_fields, register_rows = read_csv(args.register)
        audit_fields, audit_rows = read_csv(args.audit)
        fields, rows, summary = build_merge(
            register_fields, register_rows, audit_fields, audit_rows
        )

        action = "APPLY" if args.apply else "PREVIEW ONLY"
        print(f"{action}: metadata rows that would be updated: {summary['updated']}")
        print(f"API IDs not returned (reset to NOT_CHECKED): {summary['not_returned']}")
        print(f"Audit IDs not in review register: {summary['not_in_register']}")
        print("Protected fields never changed: " + ", ".join(sorted(PROTECTED_FIELDS)))
        print("No video is marked APPROVED by this utility.")

        if not args.apply:
            print("Re-run with --apply to write the metadata updates and create a backup.")
            return 0

        timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        backup = args.register.with_name(args.register.name + f".bak.{timestamp}")
        backup.write_bytes(args.register.read_bytes())
        write_csv_atomic(args.register, fields, rows)
        print(f"Backup created: {backup}")
        print(f"Review register updated: {args.register}")
        return 0

    except (MergeError, OSError, csv.Error) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
