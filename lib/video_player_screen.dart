import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
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

  Future<void> _startPlayback() async {
    if (!widget.isPlayable || _starting || _controller != null) return;

    if (!_supportsEmbeddedPlayer) {
      await _openInBrowser();
      return;
    }

    setState(() {
      _starting = true;
      _message = null;
    });

    try {
      // The player is constructed only in response to this explicit Play tap.
      final controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
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
              label: Text(appText('ভিডিও চালান', 'Play video', 'تشغيل الفيديو')),
            ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 18),
          Text(
            appText(
              'YouTube-এর নিজস্ব controls ও branding দেখানো হয়। Hover autoplay চালু নেই।',
              'YouTube controls and branding remain visible. Hover autoplay is disabled.',
              'تظل عناصر التحكم والعلامة التجارية الخاصة بـ YouTube ظاهرة. التشغيل التلقائي عند المرور بالمؤشر متوقف.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
