# Three-language translation progress

Target languages: Bangla (original), English (`en`), and Arabic (`ar`).

## Source inventory at baseline

The `feature/advanced-learning` branch contains 12 lesson JSON files with 498 lesson records and 17 quiz JSON files with 1,024 quiz records. Record IDs, lesson day/level, quiz IDs, option keys, answer keys, and original Bangla values are retained.

## Completed in this batch

- Lessons: 60 of 498 records translated into English and Arabic (all Playgroup days 1–60).
- Quiz questions: 70 of 1,024 records translated into English and Arabic (PG-001–PG-070).
- Lesson fields covered: subject, title, objective, story, examples, activity, practice, answers, parent tip.
- Quiz fields covered: subject, question, options, explanation. The `answer` remains the original A/B/C key.
- Flutter model getters now select localized text for lesson detail and quiz screens, with Bangla fallback for older records without translations.
- UI state persists selected language in SharedPreferences. Arabic sets RTL directionality. App chrome and the lesson/quiz/game screens listed above read the shared language state.
- Regression tests cover language switching, translated lesson fields, translated quiz options, answer-key stability, and legacy Bangla-only fallback.

## Remaining

- Lessons: 438 records still need reviewed English and Arabic translation.
- Quiz questions: 954 records still need reviewed English and Arabic translation.
- Main navigation, class/subject selection, lesson list and detail, quiz prompts/options/explanations/results, letter and subject game instructions, progress labels, settings labels, and key video-library controls now have translations for all three UI languages. The parent-corner content, word-gallery labels, some secondary settings/help/error text, a few dashboard labels, and several less-used dialogs still need localization review.
- Religious quotations, Qur'anic text, hadith, duas, and rulings must be checked against authoritative source text before translation; no uncertain religious wording should be altered.

## Data format

Each translated record uses a `translations` object with `en` and `ar` maps. Existing Bangla fields remain the source and fallback. Missing localized fields fall back to the original Bangla rather than displaying blank text.

The translation status must be updated only after each record and every user-facing text field in it is reviewed. Do not infer completion from file-level status alone.
