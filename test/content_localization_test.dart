import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguageController.selected.value = 'বাংলা';
  });

  test('lesson translations switch between Bangla, English and Arabic', () async {
    final lesson = Lesson.fromJson({
      'day': 1,
      'level': 'playgroup',
      'subject': 'রং',
      'title': 'লাল রং খুঁজি',
      'objective': 'লাল রং চিনে নাম বলতে পারবে।',
      'story': 'বাংলা গল্প।',
      'examples': ['লাল আপেল'],
      'activity': 'বাংলা কাজ।',
      'practice': 'বাংলা প্রশ্ন?',
      'answers': 'লাল।',
      'parent_tip': 'বাংলা পরামর্শ।',
      'translations': {
        'en': {
          'subject': 'Colors',
          'title': 'Find Red',
          'objective': 'Recognize red.',
          'story': 'An English story.',
          'examples': ['A red apple'],
          'activity': 'An English activity.',
          'practice': 'What color?',
          'answers': 'Red.',
          'parent_tip': 'An English tip.',
        },
        'ar': {
          'subject': 'الألوان',
          'title': 'ابحث عن الأحمر',
          'objective': 'تعرّف إلى اللون الأحمر.',
          'story': 'قصة عربية.',
          'examples': ['تفاحة حمراء'],
          'activity': 'نشاط عربي.',
          'practice': 'ما اللون؟',
          'answers': 'أحمر.',
          'parent_tip': 'نصيحة للأهل.',
        },
      },
    });

    expect(lesson.progressId, 'playgroup-1');
    expect(lesson.displayTitle, 'লাল রং খুঁজি');
    expect(lesson.displayExamples, ['লাল আপেল']);

    await AppLanguageController.setLanguage('English');
    expect(lesson.displaySubject, 'Colors');
    expect(lesson.displayTitle, 'Find Red');
    expect(lesson.displayExamples, ['A red apple']);
    expect(lesson.displayPractice, 'What color?');

    await AppLanguageController.setLanguage('العربية');
    expect(lesson.displayTitle, 'ابحث عن الأحمر');
    expect(lesson.displayExamples, ['تفاحة حمراء']);
    expect(lesson.displayParentTip, 'نصيحة للأهل.');
  });

  test('quiz translations preserve option keys and correct answer key', () async {
    final question = QuizQuestion.fromJson({
      'id': 'PG-001',
      'level': 'playgroup',
      'subject': 'রং',
      'question': 'লাল টমেটোর রং কী?',
      'options': {'A': 'লাল', 'B': 'নীল', 'C': 'কালো'},
      'answer': 'A',
      'explanation': 'টমেটো পাকার পর লাল হয়।',
      'translations': {
        'en': {
          'subject': 'Colors',
          'question': 'What color is a red tomato?',
          'options': {'A': 'Red', 'B': 'Blue', 'C': 'Black'},
          'explanation': 'A ripe tomato is usually red.',
        },
        'ar': {
          'subject': 'الألوان',
          'question': 'ما لون الطماطم الحمراء؟',
          'options': {'A': 'أحمر', 'B': 'أزرق', 'C': 'أسود'},
          'explanation': 'تكون الطماطم الناضجة حمراء عادةً.',
        },
      },
    });

    expect(question.id, 'PG-001');
    expect(question.answer, 'A');
    await AppLanguageController.setLanguage('English');
    expect(question.displayQuestion, 'What color is a red tomato?');
    expect(question.displayOptions.keys.toList(), ['A', 'B', 'C']);
    expect(question.displayOptions['A'], 'Red');
    expect(question.answer, 'A');

    await AppLanguageController.setLanguage('العربية');
    expect(question.displaySubject, 'الألوان');
    expect(question.displayOptions['A'], 'أحمر');
    expect(question.displayExplanation, 'تكون الطماطم الناضجة حمراء عادةً.');
    expect(question.answer, 'A');
  });

  test('legacy Bangla-only records safely fall back in every language', () async {
    final lesson = Lesson.fromJson({
      'day': 12, 'level': 'nursery', 'subject': 'বাংলা', 'title': 'অক্ষর শিখি',
      'objective': 'অক্ষর চিনব।', 'story': '', 'examples': ['অ'],
      'activity': '', 'practice': '', 'answers': '', 'parent_tip': '',
    });
    final question = QuizQuestion.fromJson({
      'id': 'OLD-001', 'level': 'nursery', 'subject': 'বাংলা',
      'question': 'কোনটি অ?', 'options': {'A': 'অ', 'B': 'ক'},
      'answer': 'A', 'explanation': 'অ একটি স্বরবর্ণ।',
    });

    for (final language in ['বাংলা', 'English', 'العربية']) {
      await AppLanguageController.setLanguage(language);
      expect(lesson.displayTitle, 'অক্ষর শিখি');
      expect(question.displayQuestion, 'কোনটি অ?');
      expect(question.displayOptions['A'], 'অ');
      expect(question.answer, 'A');
    }
  });
  test('localized starter assets contain translations for every record and field', () async {
    final lessonsRaw = await rootBundle.loadString(
      'app/src/main/assets/content/lessons/playgroup-001-010.json',
    );
    final lessons = (jsonDecode(lessonsRaw) as Map<String, dynamic>)['lessons'] as List;
    expect(lessons.length, 10);
    for (final raw in lessons) {
      final translations = raw['translations'] as Map<String, dynamic>;
      for (final language in ['en', 'ar']) {
        final fields = translations[language] as Map<String, dynamic>;
        for (final field in [
          'subject', 'title', 'objective', 'story', 'examples',
          'activity', 'practice', 'answers', 'parent_tip',
        ]) {
          expect(fields[field], isNotNull, reason: 'Day ${raw['day']} missing $language/$field');
        }
      }
    }

    final quizzesRaw = await rootBundle.loadString(
      'app/src/main/assets/content/quizzes/playgroup-001-020.json',
    );
    final questions = (jsonDecode(quizzesRaw) as Map<String, dynamic>)['questions'] as List;
    expect(questions.length, 20);
    for (final raw in questions) {
      final translations = raw['translations'] as Map<String, dynamic>;
      for (final language in ['en', 'ar']) {
        final fields = translations[language] as Map<String, dynamic>;
        for (final field in ['subject', 'question', 'options', 'explanation']) {
          expect(fields[field], isNotNull, reason: 'Question ${raw['id']} missing $language/$field');
        }
        final options = fields['options'] as Map<String, dynamic>;
        expect(options.keys.toSet(), (raw['options'] as Map).keys.toSet());
      }
      expect(raw['answer'], isIn((raw['options'] as Map).keys));
    }
  });


  test('all second Playgroup batches have complete English and Arabic translations', () async {
    final lessonsRaw = await rootBundle.loadString(
      'app/src/main/assets/content/lessons/playgroup-011-060.json',
    );
    final lessons = (jsonDecode(lessonsRaw) as Map<String, dynamic>)['lessons'] as List;
    expect(lessons.length, 50);
    for (final raw in lessons) {
      expect(raw['translations'], isA<Map>());
      for (final language in ['en', 'ar']) {
        final fields = raw['translations'][language] as Map;
        for (final field in [
          'subject', 'title', 'objective', 'story', 'examples',
          'activity', 'practice', 'answers', 'parent_tip',
        ]) {
          expect(fields[field], isNotNull, reason: 'Day ${raw['day']} missing $language/$field');
        }
      }
    }

    final quizzesRaw = await rootBundle.loadString(
      'app/src/main/assets/content/quizzes/playgroup-021-070.json',
    );
    final questions = (jsonDecode(quizzesRaw) as Map<String, dynamic>)['questions'] as List;
    expect(questions.length, 50);
    for (final raw in questions) {
      expect(raw['translations'], isA<Map>());
      for (final language in ['en', 'ar']) {
        final fields = raw['translations'][language] as Map;
        for (final field in ['subject', 'question', 'options', 'explanation']) {
          expect(fields[field], isNotNull, reason: 'Question ${raw['id']} missing $language/$field');
        }
        expect((fields['options'] as Map).keys.toSet(),
            (raw['options'] as Map).keys.toSet());
      }
      expect(raw['answer'], isIn((raw['options'] as Map).keys));
    }
  });


  test('all translated curriculum batches load complete en/ar records without changing keys', () async {
    const lessonBatches = <({String path, int first, int last, int count})>[
      (path: 'app/src/main/assets/content/lessons/playgroup-001-010.json', first: 1, last: 10, count: 10),
      (path: 'app/src/main/assets/content/lessons/playgroup-011-060.json', first: 11, last: 60, count: 50),
      (path: 'app/src/main/assets/content/lessons/nursery-061-110.json', first: 61, last: 110, count: 50),
      (path: 'app/src/main/assets/content/lessons/nursery-111-150.json', first: 111, last: 150, count: 40),
      (path: 'app/src/main/assets/content/lessons/nursery-alphabets-151-254.json', first: 151, last: 170, count: 20),
      (path: 'app/src/main/assets/content/lessons/nursery-alphabets-151-254.json', first: 171, last: 190, count: 20),
      (path: 'app/src/main/assets/content/lessons/nursery-alphabets-151-254.json', first: 191, last: 210, count: 20),
      (path: 'app/src/main/assets/content/lessons/nursery-alphabets-151-254.json', first: 211, last: 230, count: 20),
      (path: 'app/src/main/assets/content/lessons/nursery-alphabets-151-254.json', first: 231, last: 254, count: 24),
      (path: 'app/src/main/assets/content/lessons/kg-151-200.json', first: 151, last: 170, count: 20),
      (path: 'app/src/main/assets/content/lessons/kg-151-200.json', first: 171, last: 190, count: 20),
      (path: 'app/src/main/assets/content/lessons/kg-151-200.json', first: 191, last: 204, count: 14),
      (path: 'app/src/main/assets/content/lessons/kg-205-250.json', first: 205, last: 224, count: 20),
    ];
    const lessonFields = [
      'subject', 'title', 'objective', 'story', 'examples',
      'activity', 'practice', 'answers', 'parent_tip',
    ];
    var lessonTotal = 0;
    for (final batch in lessonBatches) {
      final raw = jsonDecode(await rootBundle.loadString(batch.path)) as Map<String, dynamic>;
      final records = (raw['lessons'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .where((item) => (item['day'] as num).toInt() >= batch.first &&
              (item['day'] as num).toInt() <= batch.last)
          .toList();
      expect(records.length, batch.count, reason: batch.path);
      lessonTotal += records.length;
      for (final record in records) {
        final translations = Map<String, dynamic>.from(record['translations'] as Map);
        for (final language in ['en', 'ar']) {
          final fields = Map<String, dynamic>.from(translations[language] as Map);
          for (final field in lessonFields) {
            expect(fields[field], isNotNull,
                reason: 'Day ${record['day']} missing $language/$field');
          }
        }
      }
    }
    expect(lessonTotal, 328);

    const quizBatches = <({String path, int count})>[
      (path: 'app/src/main/assets/content/quizzes/playgroup-001-020.json', count: 20),
      (path: 'app/src/main/assets/content/quizzes/playgroup-021-070.json', count: 50),
      (path: 'app/src/main/assets/content/quizzes/playgroup-071-110.json', count: 40),
      (path: 'app/src/main/assets/content/quizzes/playgroup-111-130.json', count: 20),
      (path: 'app/src/main/assets/content/quizzes/kg-001-050.json', count: 50),
      (path: 'app/src/main/assets/content/quizzes/kg-051-100.json', count: 51),
      (path: 'app/src/main/assets/content/quizzes/kg-102-151.json', count: 51),
      (path: 'app/src/main/assets/content/quizzes/nursery-001-050.json', count: 50),
      (path: 'app/src/main/assets/content/quizzes/nursery-051-100.json', count: 50),
      (path: 'app/src/main/assets/content/quizzes/nursery-101-150.json', count: 50),
      (path: 'app/src/main/assets/content/quizzes/nursery-151-200.json', count: 50),
      (path: 'app/src/main/assets/content/quizzes/nursery-201-250.json', count: 50),
    ];
    const quizFields = ['subject', 'question', 'options', 'explanation'];
    var quizTotal = 0;
    for (final batch in quizBatches) {
      final path = batch.path;
      final raw = jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
      final records = (raw['questions'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      expect(records.length, batch.count, reason: path);
      quizTotal += records.length;
      for (final record in records) {
        final translations = Map<String, dynamic>.from(record['translations'] as Map);
        final originalOptions = Map<String, dynamic>.from(record['options'] as Map);
        expect(originalOptions.containsKey(record['answer']), isTrue,
            reason: 'Answer key missing in ${record['id']}');
        for (final language in ['en', 'ar']) {
          final fields = Map<String, dynamic>.from(translations[language] as Map);
          for (final field in quizFields) {
            expect(fields[field], isNotNull,
                reason: 'Question ${record['id']} missing $language/$field');
          }
          final options = Map<String, dynamic>.from(fields['options'] as Map);
          expect(options.keys.toSet(), originalOptions.keys.toSet(),
              reason: 'Option keys changed in ${record['id']} ($language)');
        }
      }
    }
    expect(quizTotal, 532);
  });

}
