"""Unit tests for the keyless public YouTube metadata preflight."""
from __future__ import annotations

import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from urllib.error import HTTPError

import audit_youtube_videos as audit


class FakeResponse:
    status = 200

    def __init__(self, payload: dict):
        self.body = json.dumps(payload).encode("utf-8")

    def __enter__(self):
        return self

    def __exit__(self, *_args):
        return False

    def read(self):
        return self.body


class AuditHelperTests(unittest.TestCase):
    def test_catalog_loader_skips_invalid_and_duplicate_ids(self) -> None:
        payload = {"items": [
            {"video_id": "abcdefghijk", "title": "First", "channel": "Channel"},
            {"video_id": "abcdefghijk", "title": "Duplicate", "channel": "Channel"},
            {"video_id": "not-a-video-id", "title": "Invalid", "channel": "Channel"},
            {"video_id": "lmnopqrstuv", "title": "Second", "channel": "Channel"},
        ]}
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "catalog.json"
            path.write_text(json.dumps(payload), encoding="utf-8")
            records = audit.load_catalog(path)
        self.assertEqual([item["video_id"] for item in records], ["abcdefghijk", "lmnopqrstuv"])

    def test_normalized_match_handles_punctuation_and_case(self) -> None:
        self.assertEqual(audit.normalized_match("Alphabet A to Z!", "alphabet a to z"), "MATCH")
        self.assertEqual(audit.normalized_match("One title", "Different title"), "DIFFERS")
        self.assertEqual(audit.normalized_match("", "A title"), "UNKNOWN")

    def test_oembed_request_needs_no_api_key_and_returns_public_metadata(self) -> None:
        payload = {
            "provider_name": "YouTube",
            "title": "English Alphabet A to Z",
            "author_name": "Learn With Zakaria – English",
            "author_url": "https://www.youtube.com/@learnwithzakaria",
            "thumbnail_url": "https://i.ytimg.com/example.jpg",
        }
        with patch.object(audit, "urlopen", return_value=FakeResponse(payload)) as mocked:
            response, result, status = audit.fetch_oembed("abcdefghijk")
        self.assertEqual(result, "FOUND")
        self.assertEqual(status, "200")
        self.assertEqual(response["title"], payload["title"])
        request = mocked.call_args.args[0]
        self.assertIn("youtube.com/oembed?", request.full_url)
        self.assertNotIn("key=", request.full_url)

    def test_http_401_is_reported_without_claiming_exact_reason(self) -> None:
        error = HTTPError("https://www.youtube.com/oembed", 401, "Unauthorized", None, io.BytesIO(b""))
        with patch.object(audit, "urlopen", side_effect=error):
            response, result, status = audit.fetch_oembed("abcdefghijk")
        self.assertIsNone(response)
        self.assertEqual(result, "HTTP_401")
        self.assertEqual(status, "401")

    def test_public_metadata_never_approves_or_confirms_child_safety(self) -> None:
        records = [{
            "video_id": "abcdefghijk", "title": "Catalog title",
            "channel": "Catalog channel", "subject": "English", "language": "English",
        }]
        responses = {"abcdefghijk": ({
            "provider_name": "YouTube", "title": "Catalog title",
            "author_name": "Catalog channel", "author_url": "https://www.youtube.com/@channel",
        }, "FOUND", "200")}
        row = audit.build_rows(records, responses, "2026-11-19T00:00:00+00:00")[0]
        self.assertEqual(row["oembed_result"], "FOUND")
        self.assertEqual(row["title_match"], "MATCH")
        self.assertEqual(row["channel_match"], "MATCH")
        self.assertEqual(row["made_for_kids_status"], "NOT_CHECKED")
        self.assertEqual(row["embedding_status"], "NOT_CHECKED")
        self.assertEqual(row["rights_check"], "NOT_CHECKED")
        self.assertEqual(row["approval_decision"], "NOT_APPROVED_BY_PUBLIC_METADATA_AUDIT")
        self.assertEqual(row["human_content_review"], "REQUIRED")
        self.assertEqual(row["human_age_suitability_review"], "REQUIRED")
        self.assertEqual(row["human_rights_review"], "REQUIRED")

    def test_failed_public_lookup_remains_unknown_not_rejected(self) -> None:
        records = [{
            "video_id": "abcdefghijk", "title": "A title", "channel": "A channel",
            "subject": "Bangla", "language": "Bangla",
        }]
        rows = audit.build_rows(
            records, {"abcdefghijk": (None, "HTTP_404", "404")},
            "2026-11-19T00:00:00+00:00",
        )
        self.assertEqual(rows[0]["oembed_result"], "HTTP_404")
        self.assertEqual(rows[0]["title_match"], "UNKNOWN")
        self.assertEqual(rows[0]["approval_decision"], "NOT_APPROVED_BY_PUBLIC_METADATA_AUDIT")


if __name__ == "__main__":
    unittest.main()
