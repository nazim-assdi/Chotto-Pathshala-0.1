import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lessonFiles = [
    'playgroup-001-010.json', 'playgroup-011-060.json',
    'nursery-061-110.json', 'nursery-111-150.json',
    'kg-151-200.json', 'kg-205-250.json', 'kg-246-250.json',
    'class-one-251-300.json', 'class-one-306-365.json',
    'class-two-366-389.json',
  ];
  const quizFiles = [
    'class-one-001-050.json', 'class-one-051-100.json',
    'class-one-101-150.json', 'class-two-001-024.json',
    'kg-001-050.json', 'kg-051-100.json', 'kg-102-151.json',
    'nursery-001-050.json', 'nursery-051-100.json',
    'nursery-101-150.json', 'nursery-151-200.json',
    'nursery-201-250.json', 'playgroup-001-020.json',
    'playgroup-021-070.json', 'playgroup-071-110.json',
    'playgroup-111-130.json', 'supplemental-319.json',
  ];

  test('every runtime lesson file is explicitly bundled as a Flutter asset', () async {
    const runtimeLessonFiles = [
      'arabic-foundations.json',
      'class-one-251-300.json',
      'class-one-306-365.json',
      'class-two-366-389.json',
      'kg-151-200.json',
      'kg-205-250.json',
      'kg-246-250.json',
      'nursery-061-110.json',
      'nursery-111-150.json',
      'nursery-alphabets-151-254.json',
      'playgroup-001-010.json',
      'playgroup-011-060.json',
    ];

    for (final file in runtimeLessonFiles) {
      final assetPath = 'app/src/main/assets/content/lessons/$file';
      final raw = await rootBundle.loadString(assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      expect(data['lessons'], isA<List<dynamic>>(), reason: '$assetPath must have a lessons list');
      expect(
        data['lessons'],
        isNotEmpty,
        reason: '$assetPath must contain at least one lesson',
      );
    }
  });

  test('all 389 core lessons have complete content and unique level/day IDs', () async {
    final ids = <String>{};
    var count = 0;
    for (final file in lessonFiles) {
      final raw = await rootBundle.loadString('app/src/main/assets/content/lessons/$file');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final level = (data['level'] as String? ?? '').replaceAll('_', '-');
      final lessons = data['lessons'] as List<dynamic>;
      for (final value in lessons) {
        final lesson = value as Map<String, dynamic>;
        final id = '$level-${lesson['day']}';
        expect(ids.add(id), isTrue, reason: 'Duplicate lesson $id');
        for (final key in ['subject', 'title', 'objective', 'story', 'activity', 'practice', 'answers', 'parent_tip']) {
          expect((lesson[key] ?? '').toString().trim(), isNotEmpty, reason: '$file: $id missing $key');
        }
        expect(lesson['examples'], isA<List>(), reason: '$file: $id examples must be a list');
        expect((lesson['examples'] as List), isNotEmpty, reason: '$file: $id has no examples');
        count++;
      }
    }
    expect(count, 389);
    expect(ids.length, 389);
  });

  test('all quiz questions have a valid answer key', () async {
    var count = 0;
    for (final file in quizFiles) {
      final raw = await rootBundle.loadString('app/src/main/assets/content/quizzes/$file');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final value in data['questions'] as List<dynamic>) {
        final question = value as Map<String, dynamic>;
        final options = question['options'] as Map<String, dynamic>;
        expect((question['question'] ?? '').toString().trim(), isNotEmpty, reason: '$file has an empty question');
        expect(options.length, greaterThanOrEqualTo(2), reason: '$file has fewer than two options');
        expect(options.containsKey(question['answer']), isTrue, reason: '$file answer key is missing');
        count++;
      }
    }
    expect(count, 1024);
  });
}
