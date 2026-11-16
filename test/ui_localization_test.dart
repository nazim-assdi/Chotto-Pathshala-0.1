import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/main.dart';
import 'package:chotto_pathshala/word_gallery_localization.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguageController.selected.value = 'বাংলা';
  });

  test('every Word Gallery gloss has English and Arabic text', () {
    expect(wordGallerySourceGlosses, hasLength(97));
    for (final gloss in wordGallerySourceGlosses) {
      final values = wordGalleryMeaningTranslations[gloss];
      expect(values, isNotNull, reason: 'Missing translation: $gloss');
      expect(values, hasLength(2));
      expect(values![0].trim(), isNotEmpty, reason: 'Missing English: $gloss');
      expect(values[1].trim(), isNotEmpty, reason: 'Missing Arabic: $gloss');
    }
  });

  test('Word Gallery meanings switch among the three languages', () {
    const source = 'বড় সাপ';
    expect(localizeWordGalleryMeaning(source), source);
    AppLanguageController.selected.value = 'English';
    expect(localizeWordGalleryMeaning(source), 'A large snake');
    AppLanguageController.selected.value = 'العربية';
    expect(localizeWordGalleryMeaning(source), 'ثعبان كبير');
    AppLanguageController.selected.value = 'বাংলা';
    expect(localizeWordGalleryMeaning(source), source);
  });

  test('number names and digits follow the selected language', () {
    expect(localizeGalleryNumberName(1), 'এক');
    expect(localizeGalleryDigits(10), '১০');
    AppLanguageController.selected.value = 'English';
    expect(localizeGalleryNumberName(10), 'Ten');
    expect(localizeGalleryDigits(10), '10');
    AppLanguageController.selected.value = 'العربية';
    expect(localizeGalleryNumberName(10), 'عشرة');
    expect(localizeGalleryDigits(10), '١٠');
    AppLanguageController.selected.value = 'বাংলা';
    expect(localizeGalleryNumberName(10), 'দশ');
    expect(localizeGalleryDigits(10), '১০');
  });

  test('lesson-generated game question and answer keys remain stable', () {
    const lesson = Lesson(
      day: 4, level: 'playgroup', subject: 'রং', title: 'লাল রং',
      objective: 'লাল রং চেনা', story: 'গল্প', examples: ['লাল আপেল'],
      activity: 'লাল খুঁজি', practice: 'আপেলের রং কী?', answers: 'লাল',
      parentTip: 'সাহায্য করুন',
      translations: {
        'en': {'subject':'Colors','practice':'What color is the apple?','answers':'Red'},
        'ar': {'subject':'الألوان','practice':'ما لون التفاحة؟','answers':'أحمر'},
      },
    );
    final quiz = practiceQuizFromLesson(lesson);
    expect(quiz.id, 'playgroup-4');
    expect(quiz.answer, 'A');
    expect(quiz.options.keys.toList(), ['A', 'B', 'C']);
    expect(quiz.options['A'], 'লাল');

    AppLanguageController.selected.value = 'English';
    expect(quiz.displayQuestion, 'What color is the apple?');
    expect(quiz.displayOptions['A'], 'Red');
    expect(quiz.displayOptions['B'], 'Let’s read it again');

    AppLanguageController.selected.value = 'العربية';
    expect(quiz.displayQuestion, 'ما لون التفاحة؟');
    expect(quiz.displayOptions['A'], 'أحمر');
    expect(quiz.displayOptions['C'], 'ما زلت أتعلم');

    AppLanguageController.selected.value = 'বাংলা';
    expect(quiz.displayQuestion, 'আপেলের রং কী?');
    expect(quiz.displayOptions['A'], 'লাল');
  });
}
