# Three-language localization progress

Branch: `feature/advanced-learning`
Last verified: 2026-11-16

## Curriculum JSON inventory

A record-level audit covered all 12 lesson JSON files and all 17 quiz JSON files on this branch.

| Content | Bangla source records | English translations | Arabic translations |
|---|---:|---:|---:|
| Lessons | 498 | 498 | 498 |
| Quiz questions | 1,024 | 1,024 | 1,024 |

### Lesson fields checked

Every lesson record has non-empty `en` and `ar` values for:
`subject`, `title`, `objective`, `story`, `examples`, `activity`,
`practice`, `answers`, and `parent_tip`.

### Quiz fields checked

Every quiz record has non-empty `en` and `ar` values for:
`subject`, `question`, `options`, and `explanation`.
Translated option maps preserve the original option keys, and every source
`answer` still points to an existing option. IDs, lesson progress IDs, level/day
values, record order, and original Bangla fields are retained.

## This run's completed batch

- Corrected Arabic-translation numerals in 80 Class 1 supplemental math questions
  (`C1-171` through `C1-250`): 160 localized fields (`question` and
  `explanation`) now use Western digits consistently with the other Arabic
  math quiz batches. Original Bangla text and answer keys were not changed.
- Extended the full-corpus localization regression test to reject Bengali digits
  inside Arabic lesson and quiz translations.
- Added repository-level regression coverage that loads all 498 lessons and
  1,024 quiz records and checks every lesson/quiz display getter in Bangla,
  English, and Arabic while preserving option and answer keys.
- The existing Flutter models expose localized getters for all lesson fields
  and quiz subject/question/options/explanation; legacy Bangla-only records
  continue to fall back to their original fields.
- Arabic app directionality is applied at the app root, so lesson and quiz
  content, options, and result dialogs inherit RTL layout.
- Lesson search now matches the selected-language subject label as well as the
  Bangla source subject, so English/Arabic learners can search by what they see.
- All 32 subject names found across the lesson and quiz corpora, plus all five
  level names, now have English and Arabic navigation labels; dashboard class
  cards use the localized level names. Spoken praise, encouragement, and game
  completion feedback now use the selected language and matching TTS locale.

## Remaining review items

- **Curriculum review status:** all 24 Class Two lesson records carry the
  non-display metadata `review_status: "draft"`; they are translated but still
  need educational review before being treated as approved curriculum.
- **Curriculum translation quality:** structural coverage is complete, but the
  content has not received independent professional human proofreading in
  every language. Bangla script intentionally remains in English lessons that
  teach Bangla letters, words, or grammar; this is source material, not a
  missing translation.
- **General UI localization:** Word Gallery meanings, number names/digits,
  zoom controls, Video Library taxonomy, bundled summaries, loading/refresh
  messages, form validation, pagination, player status and disclosures are
  localized. Original video titles, channel names and user-authored metadata
  remain in their source language.
- **Religious content:** no Qur'anic verse, hadith quotation, dua, prophetic
  name, or religious ruling was changed or reconstructed. Video translations
  are descriptions only, not source quotations. Existing keyword screening is
  not scholarly verification; religious source material still needs
  authoritative review before publication.
- **Accessibility/device verification:** TTS voice and caption availability,
  Arabic shaping and fonts vary by device and source; visual testing on
  physical Android, Windows, macOS and iOS devices is still required.

## Validation snapshot (2026-11-16)

- Latest code commit: `1ffcf31a4b38878ded60b0393b66eab62b04a8a7`.
- GitHub Actions `flutter analyze` and `flutter test` passed in the Android
  and Windows jobs; the web job reports 22 tests passed.
- Flutter Web release build succeeded. Linux release build also succeeded.
  Android APK, Windows installer/portable bundle, macOS and unsigned iOS
  builds were still running when this snapshot was written; check the linked
  Actions runs before treating them as complete.
- Dart formatting was not run in this execution environment because no local
  Dart/Flutter executable is installed, and the repository workflows do not
  currently include a formatter step. No formatter result is claimed.
- Run links: [Flutter builds](https://github.com/nazim-assdi/Chotto-Pathshala-0.1/actions/runs/43796852721), [Web Preview](https://github.com/nazim-assdi/Chotto-Pathshala-0.1/actions/runs/43796852748), [Multi-platform Release](https://github.com/nazim-assdi/Chotto-Pathshala-0.1/actions/runs/43796852736).

## Data format and compatibility

Each translated record uses a `translations` object with `en` and `ar` maps.
Bangla remains the source of truth and fallback. Missing localized values in
older records do not render blank; model getters return the original Bangla
field. Do not mark the overall project fully localized until the general UI
review and religious-source verification items above are completed.

## Word Gallery and generated-practice localization batch

- Added `lib/word_gallery_localization.dart` with English and Arabic meanings
  for all 97 distinct Bangla glosses used by the existing Word Gallery cards.
- Added ten number names in Bangla, English and Arabic, plus Bangla, Western
  and Arabic-Indic digits.
- Localized Word Gallery guidance, category, pronunciation prompts and zoom
  tooltips.
- Lesson-derived fallback practice quizzes now use their source lesson's
  English/Arabic practice and answer translations while preserving stable
  progress IDs and correct-answer key `A`.
- Added `test/ui_localization_test.dart` for glossary completeness, number
  names/digits and generated quiz translation/answer-key stability.

## Video Library localization batch

- Added English and Arabic labels for all built-in video filter, subject,
  language and format values while keeping persisted Bangla filter keys stable.
- Added translations for all 24 bundled starter summaries and the two
  app-generated feed/custom summary strings. Original YouTube titles, channel
  names and user-entered metadata remain unchanged.
- Localized video loading and storage errors, web CORS notice, refresh results,
  add-video form labels, validation, duplicate/success feedback, search reset,
  filter summary, category cards, result counts, pagination and disclosures.
- Localized video player completion and metadata labels. YouTube caption and
  interface language follows the selected app locale when the source provides
  matching captions.
- Added regression tests for filter and summary language switching.

- Final const-safety inspection repaired dynamic localized widgets, localized the Word Gallery zoom percentage and video/library counts, and corrected the Bengali video hero punctuation.

- CI lint repair: restored `const` only on immutable children/styles around dynamic translations, keeping the runtime-localized parent widgets non-const.

- Updated the legacy Word Gallery widget test to assert the active app-language number names (rather than the old always-English number label); the dedicated unit tests exercise Bangla, English and Arabic numerals.

- `dart format` was run by the repository's Flutter runner over all five modified Dart files; the formatter changed all five and committed its output. The post-format revision is being revalidated with analyze, tests and platform builds.

- Repaired all 14 unbraced conditional statements reported by the formatter-run CI (`curly_braces_in_flow_control_structures`); this repair is being formatted and revalidated.
