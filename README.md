# ছোট্ট পাঠশালা

**শেখা হোক আনন্দের গল্প**

ছোট্ট পাঠশালা একটি Flutter-ভিত্তিক, offline-first শিশুদের শেখার অ্যাপ। Playgroup, Nursery, KG, Class One ও Class Two-এর পাঠ, ছবি, শব্দ, গেম এবং কুইজ এক জায়গায় রাখা হয়েছে।

## বর্তমান সুবিধা

- বাংলা, English ও Arabic বর্ণ/শব্দ শেখার ছবি-কার্ড এবং ভয়েস
- Playgroup, Nursery, KG, প্রথম ও দ্বিতীয় শ্রেণির পাঠ নির্বাচন
- পাঠের লক্ষ্য, গল্প, উদাহরণ, কার্যক্রম, অনুশীলন ও উত্তর
- বিষয়ভিত্তিক গেম এবং শ্রেণিভিত্তিক কুইজ
- পাঠ সম্পন্নের অগ্রগতি ডিভাইসে SharedPreferences-এ সংরক্ষণ
- ইন্টারনেট ছাড়াই স্থানীয় JSON পাঠ ও কুইজ ব্যবহার
- ডিভাইসে থাকা Text-to-Speech voice ব্যবহার; voice availability ডিভাইসভেদে ভিন্ন হতে পারে

## কনটেন্টের অবস্থান

পাঠ ও কুইজের JSON ফাইলগুলো `app/src/main/assets/content/lessons/` এবং `app/src/main/assets/content/quizzes/`-এ রাখা আছে। Flutter অ্যাপ এগুলো `pubspec.yaml`-এর asset হিসেবে লোড করে।

এই রিপোজিটরিতে পুরোনো native Android/Kotlin অ্যাপের ফাইলও রয়েছে। Flutter build-এর কাজ `feature/advanced-learning` branch-এর Flutter root (`lib/`, `pubspec.yaml`, `.github/workflows/`) থেকে হয়। পুরোনো Kotlin source আলাদা রাখা হয়েছে।

## লোকাল ডেভেলপমেন্ট

Flutter stable এবং সংশ্লিষ্ট platform toolchain ইনস্টল করে repository root-এ চালান:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Windows desktop build-এর জন্য Windows এবং Visual Studio C++ desktop workload প্রয়োজন:

```bash
flutter build windows --release
```

## GitHub Actions

`.github/workflows/flutter-build.yml` workflow `feature/advanced-learning` branch-এ পরিবর্তন হলে Android release APK এবং Windows desktop release build তৈরি ও artifact হিসেবে সংরক্ষণ করে। GitHub repository-এর **Actions** tab থেকে build status ও artifact পাওয়া যাবে।

- Android artifact: `chotto-pathshala-android-apk`
- Windows artifact: `chotto-pathshala-windows`

macOS build করতে macOS runner ও Xcode toolchain প্রয়োজন; Linux desktop build করতে Linux desktop development dependencies প্রয়োজন। এগুলো বর্তমান workflow-এ এখনো যুক্ত করা হয়নি।

## কনটেন্ট যাচাই

যদি repository-তে validation script থাকে, repository root থেকে চালান:

```bash
python scripts/validate_content.py
```

স্বয়ংক্রিয় JSON validation শিক্ষকের ভাষাগত, তথ্যগত ও বয়স-উপযোগী পর্যালোচনার বিকল্প নয়।