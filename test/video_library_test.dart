import 'package:flutter_test/flutter_test.dart';

import '../lib/video_library.dart';

void main() {
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
