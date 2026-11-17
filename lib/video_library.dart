import 'package:material_ui/material_ui.dart';

import 'app_language.dart';

/// Video playback is intentionally disabled in the child-facing release.
/// Re-enable only after every video has an individual review record and the
/// complete playback/privacy integration has been re-audited.
const bool videoLibraryAvailableForChildren = false;

class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        appText(
          'ভিডিও শেখার জগৎ',
          'Video learning world',
          'عالم التعلم بالفيديو',
        ),
      ),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 54,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                appText(
                  'ভিডিও বিভাগ সাময়িকভাবে বন্ধ',
                  'Videos are temporarily unavailable',
                  'الفيديوهات غير متاحة مؤقتًا',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                appText(
                  'শিশুদের নিরাপত্তাকে অগ্রাধিকার দিতে প্রতিটি ভিডিও আলাদাভাবে যাচাই না হওয়া পর্যন্ত YouTube ভিডিও, স্বয়ংক্রিয় channel feed এবং বাইরের player বন্ধ রাখা হয়েছে।',
                  'To put children’s safety first, YouTube playback, automatic channel feeds and external players are disabled until every video has been individually reviewed.',
                  'حرصًا على سلامة الأطفال، تم إيقاف تشغيل YouTube وخلاصات القنوات التلقائية والمشغّلات الخارجية إلى أن تتم مراجعة كل فيديو بشكل منفصل.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SafetyItem(
                        text: appText(
                          'প্রতিটি ভিডিওর বয়স-উপযোগিতা আলাদাভাবে যাচাই',
                          'Individual age-appropriateness review for every video',
                          'مراجعة ملاءمة كل فيديو للعمر بشكل منفصل',
                        ),
                      ),
                      _SafetyItem(
                        text: appText(
                          'Made for Kids অবস্থা, বিজ্ঞাপন ও গোপনীয়তার পরীক্ষা',
                          'Check Made for Kids status, ads and privacy behaviour',
                          'التحقق من حالة Made for Kids والإعلانات والخصوصية',
                        ),
                      ),
                      _SafetyItem(
                        text: appText(
                          'অনুমোদিত ভিডিও ছাড়া কোনো feed বা user-added link দেখানো হবে না',
                          'No channel feed or user-added link will appear without approval',
                          'لن تظهر خلاصات القنوات أو الروابط التي يضيفها المستخدم دون موافقة',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                appText(
                  'পাঠ, কুইজ ও অফলাইন শেখার বিষয়গুলো আগের মতোই ব্যবহার করা যাবে।',
                  'Lessons, quizzes and offline learning remain available.',
                  'تظل الدروس والاختبارات والتعلّم دون اتصال متاحة.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SafetyItem extends StatelessWidget {
  const _SafetyItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 21,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
      ],
    ),
  );
}
