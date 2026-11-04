# ছোট্ট পাঠশালা — One-Year Early Learning Book

A new Flutter learning app for early-years children, designed as a gentle digital picture-book rather than a school dashboard.

## Learning collection

- **বাংলা:** ৫০টি বর্ণ/চিহ্ন (১১ স্বরবর্ণ, ৩৫ ব্যঞ্জনবর্ণ এবং প্রচলিত ৪টি অতিরিক্ত চিহ্ন), প্রতিটির সঙ্গে শব্দ, অর্থ ও emoji.
- **English:** A–Z, ২৬টি letter, picture word, Bangla meaning and pronunciation.
- **العربية:** Alif–Ya, ২৮টি Arabic letters with vowelled starter words, Bangla meanings and pronunciation.
- **Math:** ১–১০, English and Bangla number names, quantity pictures and counting practice.
- **My World:** ৫৬ picture words across colours, shapes, fruits, vegetables, animals, birds, transport, body, family and nature.
- **Year plan:** ৫২ weeks grouped into four 13-week terms.

The 52-week scope also introduces self-awareness, feelings, family and school, hygiene, safety, manners, stories, rhymes, fine-motor practice, patterns, comparing, simple addition and subtraction, time, days and seasons.

## Child-friendly experience

- Five low-glare themes: Sage Garden, Soft Sky, Lavender Mist, Warm Paper and Night Reader.
- Themes change the complete visual treatment: palette, card geometry, book-shelf layout, spacing and home-page arrangement.
- Picture-word cards, letter details, trace-and-write prompts and speak buttons.
- Ten-question picture quiz, instant feedback, stars, celebration animation and sound.
- Offline-first lessons and locally stored progress; no child account is required.
- Responsive Flutter UI for Android, Windows and web preview.

## Pronunciation

- English words first request audio from the free [Free Dictionary API](https://dictionaryapi.dev/); the app falls back to the device's English text-to-speech voice if audio is unavailable.
- Bangla and Arabic use the device text-to-speech engine. Voice availability depends on the language packs installed on the device.
- Pronunciation works best with an internet connection for English API audio. Learning cards and progress do not require an account.

## Run locally

```bash
flutter pub get
python -m pip install pillow
python tool/generate_icon.py
flutter create --platforms=android .
python tool/prepare_android.py
dart run flutter_launcher_icons
flutter analyze
flutter test
flutter build apk --release
```

For Windows, generate its runner with `flutter create --platforms=android,windows .` and run `flutter build windows --release`.

## Curriculum approach and references

This is an original one-year sequence, not an accredited or officially endorsed curriculum. Its approach is informed by developmentally appropriate, play-based early learning: joyful active exploration, language, physical, cognitive, social and emotional growth, and partnership with families.

- [NAEYC — Developmentally Appropriate Practice](https://www.naeyc.org/resources/position-statements/dap/definition)
- [UNICEF / LEGO Foundation — Learning through Play](https://www.unicef.org/sites/default/files/2018-12/UNICEF-Lego-Foundation-Learning-through-Play.pdf)

See [content/curriculum/ONE_YEAR_PLAN.md](content/curriculum/ONE_YEAR_PLAN.md) for the scope and 52-week sequence.
