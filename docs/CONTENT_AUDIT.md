# ছোট্ট পাঠশালা — Content audit

Audit date: 2026-11-03
Branch: `feature/advanced-learning`

## Learning lessons

The ten core lesson JSON files contain **389 lessons** across five levels:

| Level | Day range | Lessons |
|---|---:|---:|
| Playgroup | 1–60 | 60 |
| Nursery | 61–150 | 90 |
| KG | 151–250 | 100 |
| Class 1 | 251–365 | 115 |
| Class 2 | 366–389 | 24 |
| **Total** | **1–389** | **389** |

The separate `arabic-foundations.json` file contains 5 supplementary Arabic lessons.

A repository audit checked all core lesson records for subject, title, objective, story, examples, activity, practice, answers, and parent_tip. The inspected records contained all required fields. A Flutter asset-integrity test now checks the full set and guards against duplicate level/day identifiers.

## Quiz bank

The 17 quiz JSON files contain **1,024 questions**. Each question was checked for a non-empty question, at least two options, and an answer key that exists in its options map. The Flutter asset-integrity test repeats these checks during CI.

## Important scope note

This audit verifies that the structured content exists and is internally complete. It is not a claim that every lesson has been independently reviewed against a national curriculum or textbook. Curriculum alignment and age-appropriateness should receive a separate educational review before publication.
