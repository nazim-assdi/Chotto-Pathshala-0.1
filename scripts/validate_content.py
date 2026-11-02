#!/usr/bin/env python3
"""Validate Gyanbari's bundled lesson and quiz JSON before an Android build.

Run from the repository root:
    python scripts/validate_content.py
The script uses only Python's standard library and never edits content files.
"""
from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "app" / "src" / "main" / "assets" / "content"
VALID_LEVELS = {"playgroup", "nursery", "kg", "class-one"}
LESSON_REQUIRED = ("level", "subject", "title", "objective", "story", "activity", "practice", "answers")
QUIZ_REQUIRED = ("id", "level", "subject", "question", "options", "answer", "explanation")


def read_records(folder: Path, collection: str, errors: list[str]):
    records = []
    files = sorted(folder.glob("*.json")) if folder.exists() else []
    if not files:
        errors.append(f"{folder.relative_to(ROOT)}: no JSON files found")
    for path in files:
        try:
            payload = json.loads(path.read_text(encoding="utf-8-sig"))
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{path.relative_to(ROOT)}: invalid JSON ({exc})")
            continue
        rows = payload.get(collection)
        if not isinstance(rows, list):
            errors.append(f"{path.relative_to(ROOT)}: missing array '{collection}'")
            continue
        for index, row in enumerate(rows, start=1):
            if not isinstance(row, dict):
                errors.append(f"{path.relative_to(ROOT)}[{index}]: record is not an object")
                continue
            row = dict(row)
            row["_source"] = f"{path.relative_to(ROOT)}[{index}]"
            if not row.get("level") and payload.get("level"):
                row["level"] = payload["level"]
            records.append(row)
    return records, len(files)


def main() -> int:
    errors: list[str] = []
    lessons, lesson_files = read_records(CONTENT / "lessons", "lessons", errors)
    quizzes, quiz_files = read_records(CONTENT / "quizzes", "questions", errors)

    lesson_keys = Counter()
    quiz_ids = Counter()
    question_texts = Counter()
    level_lessons = Counter()
    level_quizzes = Counter()

    for row in lessons:
        source = row["_source"]
        for field in LESSON_REQUIRED:
            if not str(row.get(field, "")).strip():
                errors.append(f"{source}: required lesson field '{field}' is empty")
        level = str(row.get("level", "")).strip().lower().replace("_", "-")
        if level not in VALID_LEVELS:
            errors.append(f"{source}: unknown lesson level '{level}'")
        else:
            level_lessons[level] += 1
        try:
            if int(row.get("day", 0)) < 1:
                raise ValueError
        except (TypeError, ValueError):
            errors.append(f"{source}: day must be a positive integer")
        examples = row.get("examples", [])
        if not isinstance(examples, list):
            errors.append(f"{source}: examples must be an array")
        key = (level, str(row.get("day", "")), str(row.get("subject", "")).strip())
        lesson_keys[key] += 1

    for key, count in lesson_keys.items():
        if count > 1:
            errors.append(f"duplicate lesson key {key!r} appears {count} times")

    for row in quizzes:
        source = row["_source"]
        for field in QUIZ_REQUIRED:
            if field == "options":
                continue
            if not str(row.get(field, "")).strip():
                errors.append(f"{source}: required quiz field '{field}' is empty")
        level = str(row.get("level", "")).strip().lower().replace("_", "-")
        if level not in VALID_LEVELS:
            errors.append(f"{source}: unknown quiz level '{level}'")
        else:
            level_quizzes[level] += 1
        qid = str(row.get("id", "")).strip()
        if qid:
            quiz_ids[qid] += 1
        question = " ".join(str(row.get("question", "")).split()).casefold()
        if question:
            question_texts[question] += 1
        options = row.get("options")
        if not isinstance(options, dict) or len(options) < 2:
            errors.append(f"{source}: quiz needs at least two keyed options")
        elif str(row.get("answer", "")).strip() not in options:
            errors.append(f"{source}: answer key '{row.get('answer')}' is not present in options")

    for qid, count in quiz_ids.items():
        if count > 1:
            errors.append(f"duplicate quiz id '{qid}' appears {count} times")
    for question, count in question_texts.items():
        if count > 1:
            errors.append(f"duplicate quiz question text appears {count} times: {question[:90]!r}")

    print("Gyanbari content validation")
    print(f"Lesson files: {lesson_files} | lessons: {len(lessons)}")
    print(f"Quiz files:   {quiz_files} | questions: {len(quizzes)}")
    print("Lessons by level:", dict(sorted(level_lessons.items())))
    print("Quizzes by level:", dict(sorted(level_quizzes.items())))
    if errors:
        print(f"\nFAILED: {len(errors)} issue(s)")
        for error in errors:
            print(f"- {error}")
        return 1
    print("\nPASS: all lesson and quiz records passed structural checks.")
    print("Note: this checks structure and answer-key integrity, not pedagogical accuracy.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
