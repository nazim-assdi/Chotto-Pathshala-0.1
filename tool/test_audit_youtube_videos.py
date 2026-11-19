"""Unit tests for the read-only YouTube video metadata audit."""
from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

import audit_youtube_videos as audit


class AuditHelperTests(unittest.TestCase):
    def test_api_bool_distinguishes_true_false_and_unknown(self) -> None:
        self.assertEqual(
            audit.api_bool(True, true_value="YES", false_value="NO"),
            "YES",
        )
        self.assertEqual(
            audit.api_bool(False, true_value="YES", false_value="NO"),
            "NO",
        )
        self.assertEqual(
            audit.api_bool(None, true_value="YES", false_value="NO"),
            "UNKNOWN",
        )

    def test_catalog_loader_skips_invalid_and_duplicate_ids(self) -> None:
        payload = {
            "items": [
                {"video_id": "abcdefghijk", "title": "First", "channel": "Channel"},
                {"video_id": "abcdefghijk", "title": "Duplicate", "channel": "Channel"},
                {"video_id": "not-a-video-id", "title": "Invalid", "channel": "Channel"},
                {"video_id": "lmnopqrstuv", "title": "Second", "channel": "Channel"},
            ]
        }
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "catalog.json"
            path.write_text(json.dumps(payload), encoding="utf-8")
            records = audit.load_catalog(path)

        self.assertEqual([item["video_id"] for item in records], ["abcdefghijk", "lmnopqrstuv"])

    def test_api_metadata_never_approves_a_video(self) -> None:
        records = [
            {
                "video_id": "abcdefghijk",
                "title": "Catalog title",
                "channel": "Catalog channel",
                "subject": "English",
                "language": "English",
            },
            {
                "video_id": "lmnopqrstuv",
                "title": "Missing from API",
                "channel": "Channel",
                "subject": "Bangla",
                "language": "Bangla",
            },
        ]
        api_items = {
            "abcdefghijk": {
                "id": "abcdefghijk",
                "snippet": {"title": "API title", "channelTitle": "API channel"},
                "status": {"madeForKids": False, "embeddable": True},
            }
        }

        rows = audit.build_rows(records, api_items, "2026-11-19T00:00:00+00:00")

        self.assertEqual(rows[0]["made_for_kids"], "NOT_MADE_FOR_KIDS")
        self.assertEqual(rows[0]["embeddable"], "CONFIRMED_EMBEDDABLE")
        self.assertEqual(rows[0]["api_result"], "FOUND")
        self.assertEqual(rows[0]["approval_decision"], "NOT_APPROVED_BY_API_AUDIT")
        self.assertEqual(rows[0]["human_content_review"], "REQUIRED")
        self.assertEqual(rows[0]["human_age_suitability_review"], "REQUIRED")
        self.assertEqual(rows[0]["human_rights_review"], "REQUIRED")

        self.assertEqual(rows[1]["api_result"], "NOT_RETURNED")
        self.assertEqual(rows[1]["made_for_kids"], "UNKNOWN")
        self.assertEqual(rows[1]["embeddable"], "UNKNOWN")
        self.assertEqual(rows[1]["approval_decision"], "NOT_APPROVED_BY_API_AUDIT")


if __name__ == "__main__":
    unittest.main()
