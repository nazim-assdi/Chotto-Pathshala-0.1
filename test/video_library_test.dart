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
    expect(html, contains('origin=http%3A%2F%2F127.0.0.1%3A41234'));
    expect(html, contains('widget_referrer=http%3A%2F%2F127.0.0.1%3A41234'));
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

  test('Bengali video library includes learning and Islamic sources', () {
    expect(banglaVideoFeedSourceCount, 6);
    expect(
      banglaVideoSourceNames,
      containsAll([
        'IQRA Cartoon Bangla',
        'Nobider Kahini - নবীদের কাহিনী',
        'Bangla Islamic Kids & Cartoon Videos',
        'Ustadh Aminul Islam',
        'Kids Bangla Study',
        'Kiddiestv Bangla',
      ]),
    );
  });

  test('video feed catalogue capacity includes the new Bengali sources', () {
    expect(videoFeedSourceCount, 42);
    expect(videoLibraryTheoreticalCapacity, 655);
    expect(videoLibraryTarget, greaterThanOrEqualTo(600));
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
