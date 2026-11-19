import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_language.dart';

const String privacyPolicyUrl =
    'https://nazim-assdi.github.io/Chotto-Pathshala-0.1/privacy-policy.html';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _openExternalLink(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Keep the on-screen policy content available if no browser can open.
    }
  }

  Future<void> _copyPolicyLink(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: privacyPolicyUrl));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appText(
            'গোপনীয়তা নীতির লিংক কপি হয়েছে',
            'Privacy policy link copied',
            'تم نسخ رابط سياسة الخصوصية',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        appText('গোপনীয়তা নীতি', 'Privacy policy', 'سياسة الخصوصية'),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  appText(
                    'শিশুদের গোপনীয়তা ও নিরাপত্তা',
                    'Children’s privacy and safety',
                    'خصوصية الأطفال وسلامتهم',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appText(
                    'সর্বশেষ হালনাগাদ: ১৯ নভেম্বর ২০২৬',
                    'Last updated: 19 November 2026',
                    'آخر تحديث: 19 نوفمبر 2026',
                  ),
                ),
              ],
            ),
          ),
        ),
        _PolicySection(
          title: appText('আমরা কী সংরক্ষণ করি', 'What we store', 'ما الذي نخزّنه'),
          body: appText(
            'পাঠের অগ্রগতি, নির্বাচিত ভাষা, থিম, শব্দ/ভয়েস পছন্দ, বড় লেখার সেটিংস এবং সেভ করা ভিডিওর বুকমার্ক শুধু এই ডিভাইসে স্থানীয়ভাবে সংরক্ষিত থাকে। Android রিলিজে app-data backup বন্ধ। এগুলো আমাদের সার্ভারে পাঠানো হয় না।',
            'Lesson progress, selected language, theme, sound/voice preference, large-text settings and saved-video bookmarks are stored locally on this device only. Android app-data backup is disabled in this release. They are not sent to our servers.',
            'يتم تخزين تقدم الدروس واللغة المختارة والسمة وتفضيلات الصوت وإعدادات تكبير النص وإشارات الفيديو المحفوظة محليًا على هذا الجهاز فقط. تم تعطيل النسخ الاحتياطي لبيانات التطبيق على Android في هذا الإصدار، ولا يتم إرسالها إلى خوادمنا.',
          ),
        ),
        _PolicySection(
          title: appText('আমরা যা সংগ্রহ করি না', 'What we do not collect', 'ما لا نجمعه'),
          body: appText(
            'এই সংস্করণে কোনো অ্যাকাউন্ট, নাম, ইমেইল, ফোন নম্বর, সুনির্দিষ্ট অবস্থান, পরিচিতি, ছবি, ক্যামেরা বা মাইক্রোফোনের তথ্য সংগ্রহের ব্যবস্থা নেই। অ্যাপে বিজ্ঞাপন, analytics বা tracking SDK নেই।',
            'This release has no account system and does not collect names, email addresses, phone numbers, precise location, contacts, photos, camera data or microphone recordings. It contains no advertising, analytics or tracking SDK.',
            'لا يتضمن هذا الإصدار نظام حسابات ولا يجمع الأسماء أو البريد الإلكتروني أو أرقام الهاتف أو الموقع الدقيق أو جهات الاتصال أو الصور أو بيانات الكاميرا أو تسجيلات الميكروفون. ولا يحتوي على أدوات إعلانات أو تحليلات أو تتبع.',
          ),
        ),
        _PolicySection(
          title: appText('ইন্টারনেট ও ভিডিও', 'Internet and videos', 'الإنترنت والفيديو'),
          body: appText(
            'বর্তমান default build-এ YouTube player lock করা। কোনো ভিডিও অনুমোদিত নয়, তাই এখন ভিডিও চালানো যাবে না। ভবিষ্যতে সব review ও Google child-directed setup শেষে চালু হলে, Load player চাপার পর iframe load হবে; YouTube basic technical data পেতে পারে এবং Play চাপলে playback data পেতে পারে। Autoplay বন্ধ থাকবে।',
            'The YouTube player is locked in the current default build and no video is approved. If enabled after all reviews and Google child-directed setup, the IFrame loads only after the user taps Load player; YouTube may receive basic technical data then and playback-related data after Play. Autoplay remains off.',
            'مشغل YouTube مقفل في الإصدار الافتراضي الحالي ولا يوجد فيديو معتمد. إذا تم تفعيله بعد المراجعات وإعداد Google الموجه للأطفال، فلن يتم تحميل الإطار إلا بعد الضغط على تحميل المشغل؛ وقد يتلقى YouTube بيانات تقنية أساسية ثم بيانات تشغيل إضافية بعد الضغط على تشغيل. التشغيل التلقائي متوقف.',
          ),
        ),
        _PolicySection(
          title: appText('ভয়েস / Text-to-Speech', 'Voice / text-to-speech', 'الصوت / تحويل النص إلى كلام'),
          body: appText(
            'পাঠের পূর্বনির্ধারিত লেখা উচ্চারণ করাতে ডিভাইসের operating-system text-to-speech সুবিধা ব্যবহার করা হয়। ডিভাইসে নির্বাচিত speech engine যদি অনলাইন সেবা ব্যবহার করে, সেই সেবা নিজস্ব নীতি অনুযায়ী লেখা প্রক্রিয়া করতে পারে।',
            'The device operating system’s text-to-speech service is used to speak built-in lesson text. If the speech engine selected on the device uses an online service, that provider may process the text under its own terms and privacy policy.',
            'نستخدم خدمة تحويل النص إلى كلام في نظام تشغيل الجهاز لنطق نصوص الدروس المضمنة. إذا كان محرك النطق المحدد على الجهاز يستخدم خدمة عبر الإنترنت، فقد يعالج مزود الخدمة النص وفقًا لشروطه وسياسة الخصوصية الخاصة به.',
          ),
        ),
        _PolicySection(
          title: appText('তথ্য মুছে ফেলা', 'Deleting local data', 'حذف البيانات المحلية'),
          body: appText(
            'অ্যাপের সংরক্ষিত অগ্রগতি ও পছন্দ মুছতে ডিভাইসের Settings থেকে অ্যাপের Storage/Data clear করুন অথবা অ্যাপ uninstall করুন।',
            'To remove saved progress and preferences, clear the app’s storage/data in device Settings or uninstall the app.',
            'لحذف التقدم والتفضيلات المحفوظة، امسح مساحة تخزين/بيانات التطبيق من إعدادات الجهاز أو أزل تثبيت التطبيق.',
          ),
        ),
        _PolicySection(
          title: appText('অভিভাবক ও যোগাযোগ', 'Parents and contact', 'أولياء الأمور والتواصل'),
          body: appText(
            'অভিভাবকদের শিশুদের শেখার সময় পাশে থাকার পরামর্শ দেওয়া হয়। গোপনীয়তা-সংক্রান্ত অনুরোধের জন্য Google Play Store-এ Chotto Pathshala-এর listing-এ প্রকাশিত developer contact email ব্যবহার করুন। প্রকাশের আগে listing-এ কার্যকর যোগাযোগের ইমেইল যোগ করতে হবে।',
            'Parents and caregivers should supervise children’s use. For privacy requests, use the developer contact email shown on the Chotto Pathshala Google Play listing. A working contact email must be added to that listing before publication.',
            'نوصي أولياء الأمور ومقدمي الرعاية بمتابعة استخدام الأطفال. لطلبات الخصوصية، استخدم بريد التواصل الخاص بالمطور المعروض في صفحة Chotto Pathshala على Google Play. يجب إضافة بريد إلكتروني صالح قبل النشر.',
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.link_rounded),
                title: Text(appText('অনলাইন গোপনীয়তা নীতি', 'Public privacy policy', 'سياسة الخصوصية المنشورة')),
                subtitle: const SelectableText(privacyPolicyUrl),
                trailing: const Icon(Icons.copy_rounded),
                onTap: () => _copyPolicyLink(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(appText('ব্যবহারের শর্তাবলি', 'Terms of Use', 'شروط الاستخدام')),
                onTap: () => _openExternalLink('https://nazim-assdi.github.io/Chotto-Pathshala-0.1/terms-of-use.html'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.play_circle_outline_rounded),
                title: const Text('YouTube Terms of Service'),
                onTap: () => _openExternalLink('https://www.youtube.com/t/terms'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Google Privacy Policy'),
                onTap: () => _openExternalLink('https://policies.google.com/privacy'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Chotto Pathshala',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    ),
  );
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(height: 1.5)),
        ],
      ),
    ),
  );
}
