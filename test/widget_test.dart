import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/main.dart';

void main() {
  test('all planned learning levels are available', () {
    expect(
      levels.keys,
      containsAll(['playgroup', 'nursery', 'kg', 'class-one', 'class-two']),
    );
  });

  test('Flutter app has the approved Bengali brand', () {
    expect(const ChottoPathshalaApp(), isA<ChottoPathshalaApp>());
  });

  test('learning screens use matching emoji labels', () {
    expect(levelEmoji('nursery'), '🧩');
    expect(sectionEmoji('গল্পে শিখি'), '📖');
    expect(numberEmoji(10), '🎈');
    expect(themeEmoji('dark'), '🌙');
  });

  testWidgets('lesson opens a full Reading Mode with read-aloud controls', (tester) async {
    final lesson = Lesson.fromJson({
      'day': 1,
      'level': 'playgroup',
      'subject': 'রং',
      'title': 'লাল রং খুঁজি',
      'objective': 'লাল রং চিনে নাম বলতে পারবে।',
      'story': 'একটি লাল আপেল আছে।',
      'examples': ['লাল আপেল', 'লাল ফুল'],
      'activity': 'লাল রঙের ছবি খুঁজে বের করো।',
      'practice': 'আপেলের রং কী?',
      'answers': 'লাল।',
      'parent_tip': 'শিশুকে লাল বস্তু দেখান।',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: LessonScreen(lesson: lesson, onComplete: () {}),
      ),
    );
    await tester.tap(find.byTooltip('পড়ার মোড'));
    await tester.pumpAndSettle();

    expect(find.text('পড়ার মোড'), findsOneWidget);
    expect(find.text('সব পড়ে শোনাও'), findsOneWidget);
    expect(find.text('পড়ার গতি'), findsOneWidget);
    expect(find.text('লাল রং চিনে নাম বলতে পারবে।'), findsOneWidget);
    expect(find.text('একটি লাল আপেল আছে।'), findsOneWidget);
    expect(find.byTooltip('এই অংশ পড়ে শোনাও'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('একটি লাল আপেল আছে।'), findsOneWidget);
    expect(find.byTooltip('বড় করো'), findsOneWidget);
    expect(find.byTooltip('ছোট করো'), findsOneWidget);
  });

  testWidgets('word gallery offers Bangla, English, Arabic and math 1-10', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: WordGallery())),
      ),
    );
    expect(find.text('বাংলা'), findsWidgets);
    expect(find.text('🇧🇩'), findsOneWidget);
    expect(find.text('🔠'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('গণিত ১–১০'), findsOneWidget);
    expect(find.text('অজগর'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Zebra'), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('أَسَد'), findsOneWidget);
    expect(find.text('يَد'), findsOneWidget);

    AppLanguageController.selected.value = 'English';
    await tester.tap(find.text('গণিত ১–১০'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Ten'), findsOneWidget);
  });
}
