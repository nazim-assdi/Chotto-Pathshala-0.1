import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'app_language.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.subject,
    required this.language,
    required this.isPlayable,
  });

  final String videoId;
  final String title;
  final String subject;
  final String language;
  final bool isPlayable;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  static const String _consentKey = 'youtube_player_terms_consent_v1';

  YoutubePlayerController? _controller;
  bool _starting = false;
  String? _message;
  bool _openedExternally = false;

  bool get _supportsEmbeddedPlayer =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  String _captionCode(String value) {
    if (value.toLowerCase().contains('বাংলা') ||
        value.toLowerCase().contains('bangla')) {
      return 'bn';
    }
    if (value.toLowerCase().contains('arabic') || value.contains('العربية')) {
      return 'ar';
    }
    return 'en';
  }

  String get _interfaceCode {
    switch (AppLanguageController.selected.value) {
      case 'বাংলা':
        return 'bn';
      case 'العربية':
        return 'ar';
      default:
        return 'en';
    }
  }

  Future<void> _openLegalPage(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Keep the consent dialog available if no browser can be opened.
    }
  }

  Future<bool> _requestYouTubeConsent() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_consentKey) == true) return true;
    if (!mounted) return false;

    var privacyAccepted = false;
    var youtubeTermsAccepted = false;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          title: Text(appText(
            'ভিডিও চালুর আগে সম্মতি',
            'Before loading YouTube',
            'قبل تحميل YouTube',
          )),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appText(
                  'ভিডিও প্লেয়ার লোড হলে YouTube আপনার ডিভাইস/অনুরোধের কিছু তথ্য পেতে পারে। ভিডিও Play করলে অতিরিক্ত playback তথ্যও পাঠানো হতে পারে। নিচের নীতিগুলো পড়ে সম্মতি দিন।',
                  'When the player loads, YouTube may receive basic device/request data. Starting playback may send additional playback-related data. Review the policies below before continuing.',
                  'عند تحميل المشغل، قد يتلقى YouTube بيانات أساسية عن الجهاز والطلب. وقد يؤدي بدء التشغيل إلى إرسال بيانات إضافية عن المشاهدة. يرجى مراجعة السياسات أدناه قبل المتابعة.',
                )),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _openLegalPage('https://nazim-assdi.github.io/Chotto-Pathshala-0.1/privacy-policy.html'),
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: Text(appText('Chotto Pathshala Privacy Policy', 'Chotto Pathshala Privacy Policy', 'سياسة خصوصية Chotto Pathshala')),
                ),
                TextButton.icon(
                  onPressed: () => _openLegalPage('https://nazim-assdi.github.io/Chotto-Pathshala-0.1/terms-of-use.html'),
                  icon: const Icon(Icons.description_outlined),
                  label: Text(appText('ব্যবহারের শর্তাবলি', 'Terms of Use', 'شروط الاستخدام')),
                ),
                TextButton.icon(
                  onPressed: () => _openLegalPage('https://www.youtube.com/t/terms'),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('YouTube Terms of Service'),
                ),
                TextButton.icon(
                  onPressed: () => _openLegalPage('https://policies.google.com/privacy'),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Google Privacy Policy'),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: privacyAccepted,
                  onChanged: (value) => updateDialog(() => privacyAccepted = value ?? false),
                  title: Text(appText(
                    'আমি Chotto Pathshala-এর Privacy Policy পড়েছি ও মেনে নিচ্ছি।',
                    'I have read and agree to the Chotto Pathshala Privacy Policy.',
                    'لقد قرأت سياسة خصوصية Chotto Pathshala وأوافق عليها.',
                  )),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: youtubeTermsAccepted,
                  onChanged: (value) => updateDialog(() => youtubeTermsAccepted = value ?? false),
                  title: Text(appText(
                    'আমি YouTube Terms of Service মেনে নিচ্ছি।',
                    'I agree to the YouTube Terms of Service.',
                    'أوافق على شروط خدمة YouTube.',
                  )),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(appText('বাতিল', 'Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: privacyAccepted && youtubeTermsAccepted
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
              child: Text(appText('সম্মতি দিয়ে এগিয়ে যান', 'Agree and continue', 'أوافق وأتابع')),
            ),
          ],
        ),
      ),
    );

    if (accepted != true || !mounted) return false;
    await preferences.setBool(_consentKey, true);
    return true;
  }

  Future<void> _startPlayback() async {
    if (!widget.isPlayable || _starting || _controller != null) return;
    final consented = await _requestYouTubeConsent();
    if (!consented || !mounted) return;

    if (!_supportsEmbeddedPlayer) {
      await _openInBrowser();
      return;
    }

    setState(() {
      _starting = true;
      _message = null;
    });

    try {
      // The iframe is created only after the explicit Load-player tap and remains paused.
      final controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: false,
        params: YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          privacyEnhancedMode: true,
          strictRelatedVideos: true,
          enableCaption: true,
          captionLanguage: _captionCode(widget.language),
          interfaceLanguage: _interfaceCode,
          playsInline: true,
        ),
      );

      if (!mounted) {
        unawaited(controller.close());
        return;
      }

      setState(() {
        _controller = controller;
        _starting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _message = appText(
          'ভিডিও চালু করা যায়নি। ইন্টারনেট সংযোগ ও ভিডিওর অনুমতি যাচাই করে আবার চেষ্টা করো।',
          'The video could not start. Check the internet connection and video availability, then try again.',
          'تعذر تشغيل الفيديو. تحقق من الاتصال بالإنترنت وإمكانية تشغيل الفيديو ثم حاول مرة أخرى.',
        );
      });
    }
  }

  Future<void> _openInBrowser() async {
    if (!widget.isPlayable || _starting) return;
    setState(() {
      _starting = true;
      _message = null;
    });

    try {
      final uri = Uri.https(
        'www.youtube.com',
        '/watch',
        <String, String>{'v': widget.videoId},
      );
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      setState(() {
        _starting = false;
        _openedExternally = opened;
        _message = opened
            ? appText(
                'YouTube তোমার browser-এ খোলা হয়েছে। ভিডিওটি সেখানেই চালানো যাবে।',
                'YouTube opened in your browser. Continue playback there.',
                'تم فتح YouTube في المتصفح. يمكنك متابعة التشغيل هناك.',
              )
            : appText(
                'YouTube খোলা যায়নি। ডিভাইসে browser আছে কি না যাচাই করো।',
                'Could not open YouTube. Check that a browser is available.',
                'تعذر فتح YouTube. تحقق من توفر متصفح على الجهاز.',
              );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _message = appText(
          'YouTube খোলা যায়নি। পরে আবার চেষ্টা করো।',
          'Could not open YouTube. Please try again.',
          'تعذر فتح YouTube. حاول مرة أخرى.',
        );
      });
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      unawaited(controller.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: _controller == null
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(
                        child: _starting
                            ? const CircularProgressIndicator()
                            : Icon(
                                _openedExternally
                                    ? Icons.open_in_new_rounded
                                    : Icons.play_circle_outline_rounded,
                                size: 72,
                                color: scheme.primary,
                              ),
                      ),
                    )
                  : YoutubePlayer(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.subject} • ${widget.language}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          if (!widget.isPlayable)
            Text(
              appText(
                'এই ভিডিওটি শিশুদের জন্য অনুমোদিত নয়।',
                'This video is not approved for children.',
                'هذا الفيديو غير معتمد للأطفال.',
              ),
              style: TextStyle(color: scheme.error),
            )
          else if (_controller == null)
            FilledButton.icon(
              onPressed: _starting ? null : _startPlayback,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(appText('ভিডিও প্লেয়ার খুলুন', 'Load video player', 'فتح مشغل الفيديو')),
            ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 18),
          Text(
            appText(
              'YouTube-এর নিজস্ব controls ও branding দেখানো হয়। Player load হওয়ার পর YouTube-এর Play control চাপলে ভিডিও শুরু হবে।',
              'YouTube controls and branding remain visible. Start playback with YouTube’s own Play control after the player loads.',
              'تظل عناصر التحكم والعلامة التجارية الخاصة بـ YouTube ظاهرة. ابدأ الفيديو باستخدام زر التشغيل الخاص بـ YouTube بعد تحميل المشغل.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
