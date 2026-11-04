import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotto_pathshala/learning_data.dart';
import 'package:chotto_pathshala/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the one-year curriculum has 52 weekly lessons', () {
    expect(yearPlan, hasLength(52));
    expect(yearPlan.first.week, 1);
    expect(yearPlan.last.week, 52);
  });

  test('the core alphabet and number collections have exact counts', () {
    expect(banglaLetters, hasLength(50));
    expect(englishLetters, hasLength(26));
    expect(arabicLetters, hasLength(28));
    expect(mathNumbers, hasLength(10));
    expect(discoveryWords.length, greaterThanOrEqualTo(50));
    expect(banglaLetters.map((item) => item.id).toSet(), hasLength(50));
    expect(englishLetters.map((item) => item.id).toSet(), hasLength(26));
    expect(arabicLetters.map((item) => item.id).toSet(), hasLength(28));
  });

  test('each learning card has a word, meaning, emoji and pronunciation cue', () {
    for (final item in allLearningItems) {
      expect(item.word.trim(), isNotEmpty, reason: item.id);
      expect(item.meaning.trim(), isNotEmpty, reason: item.id);
      expect(item.emoji.trim(), isNotEmpty, reason: item.id);
      expect(item.reading.trim(), isNotEmpty, reason: item.id);
    }
  });

  testWidgets('the new app opens with the Bengali learning home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ChottoPathshalaApp());
    await tester.pumpAndSettle();
    expect(find.text('ছোট্ট পাঠশালা'), findsOneWidget);
    expect(find.text('তোমার বইয়ের তাক'), findsOneWidget);
    expect(find.text('আমার বই'), findsOneWidget);
  });
}
