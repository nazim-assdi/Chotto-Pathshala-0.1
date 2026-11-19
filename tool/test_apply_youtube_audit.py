"""Unit tests for importing YouTube API metadata without approving videos."""
from __future__ import annotations

import unittest

from apply_youtube_audit import MergeError, build_merge


REGISTER_FIELDS = [
    "record_type",
    "video_id_or_source_id",
    "review_status",
    "reviewer",
    "review_date",
    "age_band",
    "made_for_kids_status",
    "rights_check",
    "embedding_status",
    "review_notes",
]
AUDIT_FIELDS = [
    "checked_at_utc",
    "video_id",
    "api_result",
    "made_for_kids",
    "embeddable",
]


class ApplyAuditTests(unittest.TestCase):
    def setUp(self) -> None:
        self.register_rows = [
            {
                "record_type": "bundled_video",
                "video_id_or_source_id": "abcdefghijk",
                "review_status": "PENDING_REVIEW",
                "reviewer": "",
                "review_date": "",
                "age_band": "",
                "made_for_kids_status": "NOT_CHECKED",
                "rights_check": "",
                "embedding_status": "NOT_CHECKED",
                "review_notes": "Human review required",
            },
            {
                "record_type": "collected_video_candidate",
                "video_id_or_source_id": "lmnopqrstuv",
                "review_status": "PENDING_REVIEW",
                "reviewer": "",
                "review_date": "",
                "age_band": "",
                "made_for_kids_status": "CONFIRMED_MADE_FOR_KIDS",
                "rights_check": "",
                "embedding_status": "CONFIRMED_EMBEDDABLE",
                "review_notes": "Previously fetched API result",
            },
            {
                "record_type": "feed_source_candidate",
                "video_id_or_source_id": "UC1234567890",
                "review_status": "SOURCE_ONLY_NOT_APPROVED",
                "reviewer": "",
                "review_date": "",
                "age_band": "",
                "made_for_kids_status": "NOT_APPLICABLE",
                "rights_check": "",
                "embedding_status": "NOT_APPLICABLE",
                "review_notes": "Do not import channel feeds",
            },
        ]

    def test_found_api_metadata_updates_only_metadata_columns(self) -> None:
        audit_rows = [
            {
                "checked_at_utc": "2026-11-19T00:00:00+00:00",
                "video_id": "abcdefghijk",
                "api_result": "FOUND",
                "made_for_kids": "CONFIRMED_MADE_FOR_KIDS",
                "embeddable": "CONFIRMED_EMBEDDABLE",
            }
        ]
        fields, rows, summary = build_merge(
            REGISTER_FIELDS, self.register_rows, AUDIT_FIELDS, audit_rows
        )

        first = rows[0]
        self.assertEqual(first["made_for_kids_status"], "CONFIRMED_MADE_FOR_KIDS")
        self.assertEqual(first["embedding_status"], "CONFIRMED_EMBEDDABLE")
        self.assertEqual(first["youtube_api_checked_at"], "2026-11-19T00:00:00+00:00")
        for protected in ("review_status", "reviewer", "review_date", "age_band", "rights_check"):
            self.assertEqual(first[protected], self.register_rows[0][protected])
        self.assertEqual(first["review_status"], "PENDING_REVIEW")
        self.assertIn("youtube_api_checked_at", fields)
        self.assertEqual(summary["updated"], 1)
        self.assertEqual(summary["not_in_register"], 0)

    def test_missing_api_result_resets_metadata_to_not_checked(self) -> None:
        audit_rows = [
            {
                "checked_at_utc": "2026-11-19T00:00:00+00:00",
                "video_id": "lmnopqrstuv",
                "api_result": "NOT_RETURNED",
                "made_for_kids": "UNKNOWN",
                "embeddable": "UNKNOWN",
            }
        ]
        _, rows, summary = build_merge(
            REGISTER_FIELDS, self.register_rows, AUDIT_FIELDS, audit_rows
        )
        second = rows[1]
        self.assertEqual(second["made_for_kids_status"], "NOT_CHECKED")
        self.assertEqual(second["embedding_status"], "NOT_CHECKED")
        self.assertEqual(second["review_status"], "PENDING_REVIEW")
        self.assertEqual(summary["not_returned"], 1)

    def test_api_metadata_cannot_approve_or_verify_rights(self) -> None:
        audit_rows = [
            {
                "checked_at_utc": "2026-11-19T00:00:00+00:00",
                "video_id": "abcdefghijk",
                "api_result": "FOUND",
                "made_for_kids": "CONFIRMED_MADE_FOR_KIDS",
                "embeddable": "CONFIRMED_EMBEDDABLE",
            }
        ]
        _, rows, _ = build_merge(
            REGISTER_FIELDS, self.register_rows, AUDIT_FIELDS, audit_rows
        )
        self.assertNotEqual(rows[0]["review_status"], "APPROVED")
        self.assertEqual(rows[0]["age_band"], "")
        self.assertEqual(rows[0]["rights_check"], "")

    def test_unknown_values_fail_closed(self) -> None:
        audit_rows = [
            {
                "checked_at_utc": "2026-11-19T00:00:00+00:00",
                "video_id": "abcdefghijk",
                "api_result": "FOUND",
                "made_for_kids": "UNKNOWN",
                "embeddable": "UNKNOWN",
            }
        ]
        _, rows, _ = build_merge(
            REGISTER_FIELDS, self.register_rows, AUDIT_FIELDS, audit_rows
        )
        self.assertEqual(rows[0]["made_for_kids_status"], "NOT_CHECKED")
        self.assertEqual(rows[0]["embedding_status"], "NOT_CHECKED")

    def test_duplicate_audit_ids_are_rejected(self) -> None:
        audit_row = {
            "checked_at_utc": "2026-11-19T00:00:00+00:00",
            "video_id": "abcdefghijk",
            "api_result": "FOUND",
            "made_for_kids": "CONFIRMED_MADE_FOR_KIDS",
            "embeddable": "CONFIRMED_EMBEDDABLE",
        }
        with self.assertRaises(MergeError):
            build_merge(
                REGISTER_FIELDS, self.register_rows, AUDIT_FIELDS,
                [audit_row, dict(audit_row)],
            )

    def test_feed_source_records_are_never_updated(self) -> None:
        audit_rows = [
            {
                "checked_at_utc": "2026-11-19T00:00:00+00:00",
                "video_id": "UC1234567890",
                "api_result": "FOUND",
                "made_for_kids": "CONFIRMED_MADE_FOR_KIDS",
                "embeddable": "CONFIRMED_EMBEDDABLE",
            }
        ]
        _, rows, summary = build_merge(
            REGISTER_FIELDS, self.register_rows, AUDIT_FIELDS, audit_rows
        )
        self.assertEqual(rows[2]["made_for_kids_status"], "NOT_APPLICABLE")
        self.assertEqual(rows[2]["embedding_status"], "NOT_APPLICABLE")
        self.assertEqual(summary["not_in_register"], 1)


if __name__ == "__main__":
    unittest.main()
