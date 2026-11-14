# ছোট্ট পাঠশালা

**শেখা হোক আনন্দের গল্প**

ছোট্ট পাঠশালা একটি Flutter-ভিত্তিক, offline-first শিশুদের শেখার অ্যাপ। Playgroup, Nursery, KG, Class One ও Class Two-এর পাঠ, ছবি, শব্দ, গেম এবং কুইজ এক জায়গায় রাখা হয়েছে।

## বর্তমান সুবিধা

- বাংলা, English ও Arabic বর্ণ/শব্দ শেখার ছবি-কার্ড এবং ভয়েস
- বাংলা ভাষার শিশুদের শেখার ভিডিও, বাংলা ইসলামিক শিক্ষা, নবীদের কাহিনী, কুরআন শেখা ও ইসলামিক কার্টুনের আলাদা বিভাগ
- ৬০০ ভিডিওর সংগ্রহ-লক্ষ্যসহ searchable video library; বাংলা, English, Arabic, ইসলাম শিক্ষা, বিজ্ঞান, গণিত ও কার্টুনের feed
- নিজের পছন্দের YouTube URL/ID ভিডিও লাইব্রেরিতে যোগ করা যায়; সাধারণ YouTube search বা Shorts browser নেই
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

## Video library and platform notes

The video library has no parent-mode lock or per-video approval gate. It now includes 42 named YouTube channel feeds and 25 bundled starter videos. On a single clean refresh, the feed importer can request up to 15 recent entries from each source, giving a theoretical initial collection ceiling of 655 entries (42 × 15 + 25). This is a capacity ceiling, not a statement that 655 videos are already present: feeds can fail, return fewer entries, contain duplicates, or have videos removed. The app displays the actual number currently available on the device and caches imported feed entries locally.

The six Bengali-language feed sources added in this release are IQRA Cartoon Bangla, Nobider Kahini, Bangla Islamic Kids & Cartoon Videos, Ustadh Aminul Islam, Kids Bangla Study and Kiddiestv Bangla. These were selected from public channel descriptions and channel references; the app classifies feeds by source channel, not by watching every upload. Searchable quick collections include Bengali learning, Bengali Islamic learning, Islamic cartoons and all videos. The app also includes individually identified Bengali starter videos, including Bangla vowels and a Bangla Quran-learning lesson.

The channel/feed list mixes Islamic learning and cartoons with language, early-learning, maths, science, general-knowledge and creative-learning sources. A channel label or title is not a video-level content review. The app does not automatically inspect the full visual/audio content, religious accuracy, age suitability, instruments, sponsorships or advertisements. YouTube may display ads or platform overlays that the app cannot fully control. The list is a curated discovery collection, not a certification that every video is Islamic or completely safe.

Search, subject, language and format filters are available; video cards are paginated 30 at a time and use a responsive grid on larger screens. Users can add a YouTube URL or video ID directly. Feed refresh is supported on native platforms; Web preview may be blocked by browser CORS restrictions. The embedded player uses YouTube privacy-enhanced mode and does not automatically start the next video. Windows and Linux open a dedicated player window owned by the app, using WebView2 on Windows and WebKitGTK 4.1 on Linux. The desktop player loads a local loopback page that embeds YouTube's privacy-enhanced player and sends an HTTP Referer, which YouTube requires for embedded playback. It does not automatically start another video. Windows requires the Microsoft Edge WebView2 Runtime (included with Windows 11; it may need installing on some Windows 10 PCs). Linux requires `libwebkit2gtk-4.1-0` and `libsoup-3.0-0` at runtime. On Ubuntu/Debian, install them with `sudo apt install libwebkit2gtk-4.1-0 libsoup-3.0-0`.
