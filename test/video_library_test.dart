import 'package:flutter_test/flutter_test.dart';

import 'package:chotto_pathshala/video_library.dart';
import 'package:chotto_pathshala/desktop_video_embed.dart';

void main() {
  test('desktop YouTube embed includes a referrer and privacy mode', () {
    final html = buildDesktopVideoEmbedHtml(
      'AwccZotbJS4',
      Uri(scheme: 'http', host: '127.0.0.1', port: 41234),
    );
    expect(html, contains('https://www.youtube-nocookie.com/embed/AwccZotbJS4'));
    expect(html, contains('referrerpolicy="strict-origin-when-cross-origin"'));
    expect(html, contains('name="referrer" content="strict-origin-when-cross-origin"'));
    expect(html, contains('origin=http://127.0.0.1:41234'));
    expect(html, contains('widget_referrer=http://127.0.0.1:41234'));
  });

  test('desktop embed rejects malformed YouTube video IDs', () {
    expect(
      () => buildDesktopVideoEmbedHtml(
        'not-a-valid-id',
        Uri(scheme: 'http', host: '127.0.0.1', port: 41234),
      ),
      throwsFormatException,
    );
  });

  test('video library is designed for at least 500 entries', () {
    expect(videoLibraryTarget, greaterThanOrEqualTo(500));
  });

  test('LearningVideo JSON round-trips its video format', () {
    const original = LearningVideo(
      id: 'AwccZotbJS4',
      title: 'Islamic Learning for Kids in Arabic',
      subject: 'ইসলাম শিক্ষা',
      language: 'Arabic',
      channel: 'Kalam Kids',
      summary: 'Arabic Islamic lesson',
      format: 'ইসলামিক কার্টুন',
    );

    final restored = LearningVideo.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.subject, original.subject);
    expect(restored.language, original.language);
    expect(restored.channel, original.channel);
    expect(restored.summary, original.summary);
    expect(restored.format, 'ইসলামিক কার্টুন');
  });

  test('old saved video records default to educational lesson format', () {
    final restored = LearningVideo.fromJson({
      'id': 'ASXzhX-J598',
      'title': 'English Alphabet A to Z',
      'subject': 'English',
      'language': 'English',
      'channel': 'Learn With Zakaria',
      'summary': 'Alphabet basics',
    });

    expect(restored.format, 'শিক্ষামূলক পাঠ');
  });
}
