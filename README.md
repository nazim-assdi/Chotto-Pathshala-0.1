# ছোট্ট পাঠশালা

**শেখা হোক আনন্দের গল্প**

ছোট্ট পাঠশালা একটি Flutter-ভিত্তিক, offline-first শিশুদের শেখার অ্যাপ। Playgroup, Nursery, KG, Class One ও Class Two-এর পাঠ, ছবি, শব্দ, গেম এবং কুইজ এক জায়গায় রাখা হয়েছে।

## বর্তমান সুবিধা

- বাংলা, English ও Arabic বর্ণ/শব্দ শেখার ছবি-কার্ড এবং ভয়েস
- ইসলামিক-ফিল্টার করা শিক্ষামূলক ভিডিও লাইব্রেরি; English ও Arabic কনটেন্ট অগ্রাধিকার
- অভিভাবক-যাচাই ব্যবস্থা: preview সম্পূর্ণ না করে কোনো ভিডিও শিশুদের তালিকায় অনুমোদন করা যায় না
- অভিভাবক YouTube URL/ID যোগ করতে পারেন; সাধারণ YouTube search/feed/Shorts অ্যাপে নেই
- Playgroup, Nursery, KG, প্রথম ও দ্বিতীয় শ্রেণির পাঠ নির্বাচন
- পাঠের লক্ষ্য, গল্প, উদাহরণ, কার্যক্রম, অনুশীলন ও উত্তর
- বিষয়ভিত্তিক গেম এবং শ্রেণিভিত্তিক কুইজ
- পাঠ সম্পন্নের অগ্রগতি ডিভাইসে SharedPreferences-এ সংরক্ষণ
- ইন্টারনেট ছাড়াই স্থানীয় JSON পাঠ ও কুইজ ব্যবহার
- ডিভাইসে থাকা Text-to-Speech voice ব্যবহার; voice availability ডিভাইসভেদে ভিন্ন হতে পারে

## Project structure

- `lib/` — Flutter/Dart application source
- `assets/` — application images and visual assets
- `app/src/main/assets/content/` — bundled lesson and quiz JSON data
- `test/` — Flutter tests
- `tool/` — asset and icon generation tools
- `scripts/` — content validation utilities
- `.github/workflows/` — Flutter Android, Windows and Web build workflows

এই repository-তে Flutter project ও তার প্রয়োজনীয় content/assets রাখা হয়েছে। পুরোনো Kotlin Android, Compose Desktop এবং Swift iOS implementation সরানো হয়েছে।

## Run locally

Flutter stable SDK ইনস্টল করে repository root-এ চালান:

```bash
flutter create --platforms=android,windows,web .
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Windows build:

```bash
flutter build windows --release
```

## GitHub Actions

- `Flutter builds` — Android release APK ও Windows build তৈরি করে
- `Flutter Web Preview` — Flutter web preview তৈরি করে

GitHub repository-এর **Actions** tab থেকে build status ও artifacts পাওয়া যাবে।

## Content validation

```bash
python scripts/validate_content.py
```

স্বয়ংক্রিয় JSON validation শিক্ষকের ভাষাগত, তথ্যগত ও বয়স-উপযোগী পর্যালোচনার বিকল্প নয়।

## Video library safety and platform notes

The video catalog is a parent-reviewed allowlist, not an open YouTube browser. Starter entries are pending by default. A parent must pass the in-app parent check, preview a video to completion, and explicitly approve it before it appears in child mode. Parents can add a YouTube video URL or ID; newly added entries are never automatically approved. The embedded player uses YouTube's privacy-enhanced mode, hides its standard controls, restricts related videos to the same channel where supported, and closes the player view after playback ends. This reduces exposure but cannot guarantee removal of every YouTube-served advertisement or platform overlay; parents must review content.

The official youtube_player_iframe plugin supports Android, iOS, macOS and Web. Windows and Linux builds keep the curated catalog but do not open YouTube outside the app; use a supported player platform for preview/playback.


The video library now includes 34 fixed discovery feeds spanning Arabic/English learning, Islamic cartoons and stories, early literacy, maths, science, general knowledge and creative learning. On supported native platforms, the app imports up to 15 recent feed entries per source and caches the results locally; the theoretical cap is 510 remote candidates plus the 17 starter entries, but the actual count depends on how many public feeds respond and how many uploads are available. The app displays the real discovered count instead of claiming that every source returned 15 items. Feed entries are only candidates: channel-level reputation is not a content safety guarantee, and every individual video remains hidden from children until a parent previews it and approves it. Web builds may not refresh feeds because browser CORS restrictions can block YouTube's Atom feed.