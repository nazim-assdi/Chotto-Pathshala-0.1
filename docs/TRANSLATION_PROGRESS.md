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

## Remaining review items

- **Curriculum review status:** all 24 Class Two lesson records carry the
  non-display metadata `review_status: "draft"`; they are translated but still
  need educational review before being treated as approved curriculum.
- **Curriculum translation quality:** structural coverage is complete, but the
  content has not received independent professional human proofreading in
  every language. Bangla script intentionally remains in English lessons that
  teach Bangla letters, words, or grammar; this is source material, not a
  missing translation.
- **General UI localization:** progress-screen headings, Parent Corner guidance,
  dashboard summary/shortcuts, More-hub navigation, and lesson search labels now
  have three-language strings. Remaining review includes word-gallery meanings
  and zoom/tooltips, some secondary settings/help/error messages, video-library
  loading/refresh/status messages, and a few secondary labels. Main navigation,
  lesson list/detail, quiz prompts/options/explanations/results, and primary
  dashboard shortcuts are localized.
- **Religious content:** no Qur'anic verse, hadith quotation, dua, prophetic
  name, or religious ruling was altered in this batch. A keyword screen across
  all lesson and quiz JSON did not flag explicit Qur'an/hadith/dua/ruling text;
  the Arabic-foundation records teach letters, vowel marks and simple words.
  This screen is not a scholarly review. Any religious source text added later
  must be checked against an authoritative source; uncertain material must
  remain flagged rather than being reconstructed or machine-altered.

## Data format and compatibility

Each translated record uses a `translations` object with `en` and `ar` maps.
Bangla remains the source of truth and fallback. Missing localized values in
older records do not render blank; model getters return the original Bangla
field. Do not mark the overall project fully localized until the general UI
review and religious-source verification items above are completed.
