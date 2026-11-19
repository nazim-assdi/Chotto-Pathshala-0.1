import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/video_library.dart';

class _FakeVideoLibraryRepository extends VideoLibraryRepository {
  @override
  Future<List<VideoCatalogItem>> load() async => List<VideoCatalogItem>.generate(
        25,
        (index) => VideoCatalogItem(
          videoId: 'TVideo${index.toString().padLeft(5, '0')}',
          title: index == 0
              ? 'English Alphabet A to Z'
              : index == 1
                  ? 'বাংলা স্বরবর্ণ শেখা'
                  : 'Learning video $index',
          channel: 'Chotto Pathshala test library',
          subject: index == 1
              ? 'বাংলা'
              : index == 3
                  ? 'সাধারণ জ্ঞান'
                  : 'English',
          language: index == 1 ? 'বাংলা' : 'English',
          reviewStatus: index == 2 ? 'APPROVED' : 'PENDING_REVIEW',
          ageBand: index == 2 ? '3-5' : '',
          madeForKidsStatus:
              index == 2 ? 'CONFIRMED_MADE_FOR_KIDS' : 'NOT_CHECKED',
          rightsCheck: index == 2 ? 'CONFIRMED' : '',
        ),
      );
}

Future<void> _pumpVideoLibrary(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: VideoLibraryScreen(repository: _FakeVideoLibraryRepository()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguageController.selected.value = 'বাংলা';
  });

  test('catalogue parser validates IDs, removes duplicates and caps at target', () {
    const raw = '''
    {
      "items": [
        {"video_id":"TVideo00001","title":"  First video  ","channel":" Test channel ","subject":" English "},
        {"video_id":"TVideo00001","title":"Duplicate video","channel":"Test channel"},
        {"video_id":"not-valid","title":"Invalid ID","channel":"Test channel"},
        {"video_id":"TVideo00002","title":"Second video","channel":"Test channel"}
      ]
    }
    ''';
    final items = VideoLibraryRepository().parse(raw);

    expect(videoLibraryTargetCount, 2000);
    expect(videoLibraryPageSize, 20);
    expect(items.map((item) => item.videoId).toList(),
        ['TVideo00001', 'TVideo00002']);
    expect(items.every((item) => item.reviewStatus == 'PENDING_REVIEW'), isTrue);
    expect(items.any((item) => item.isApproved), isFalse);
    expect(videoLibraryAvailableForChildren, isFalse);
  });

  test('catalogue parser loads beyond 1,000 and caps safely at 2,000', () {
    final raw = jsonEncode({
      'items': List.generate(
        videoLibraryTargetCount + 25,
        (index) => {
          'video_id': 'V${index.toString().padLeft(10, '0')}',
          'title': 'Learning video $index',
          'channel': 'Test channel',
          'subject': 'English',
          'language': 'English',
          'review_status': 'PENDING_REVIEW',
        },
      ),
    });

    final items = VideoLibraryRepository().parse(raw);

    expect(items.length, 2000);
    expect(items.length, greaterThan(1000));
    expect(items.last.videoId, 'V0000001999');
  });

  testWidgets('video library shows search, categories and truthful counters', (tester) async {
    await _pumpVideoLibrary(tester);

    expect(find.text('ভিডিও শেখার সংগ্রহ'), findsOneWidget);
    expect(find.text('ভিডিও বা বিষয় খুঁজুন...'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('subject filters are built dynamically from catalogue data',
      (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.ensureVisible(find.text('সাধারণ জ্ঞান (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('সাধারণ জ্ঞান (1)'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2500));
    await tester.pumpAndSettle();

    expect(find.text('Learning video 3'), findsOneWidget);
    expect(find.text('English Alphabet A to Z'), findsNothing);
    expect(find.text('1টি ভিডিও রেকর্ড'), findsOneWidget);
  });

  testWidgets('subject, language and search filters combine and clear together',
      (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.tap(find.text('সাধারণ জ্ঞান (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('আরও ফিল্টার'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Language: English (24)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language: English (24)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Learning video 3');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2500));
    await tester.pumpAndSettle();

    expect(find.text('Learning video 3'), findsOneWidget);
    expect(find.text('English Alphabet A to Z'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 2500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ফিল্টার মুছুন'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ফিল্টার মুছুন'));
    await tester.pumpAndSettle();

    expect(find.text('25 video records'), findsNothing);
    expect(find.text('25টি ভিডিও রেকর্ড'), findsOneWidget);
  });

  testWidgets('language filter shows records only in the selected language',
      (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.tap(find.text('আরও ফিল্টার'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ভাষা: বাংলা (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ভাষা: বাংলা (1)'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2500));
    await tester.pumpAndSettle();

    expect(find.text('বাংলা স্বরবর্ণ শেখা'), findsOneWidget);
    expect(find.text('English Alphabet A to Z'), findsNothing);
    expect(find.text('1টি ভিডিও রেকর্ড'), findsOneWidget);
  });

  testWidgets('approved filter is isolated and playback remains gated',
      (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.tap(find.text('আরও ফিল্টার'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('অনুমোদিত (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('অনুমোদিত (1)'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2500));
    await tester.pumpAndSettle();

    expect(find.text('Learning video 2'), findsOneWidget);
    expect(find.text('English Alphabet A to Z'), findsNothing);

    await tester.tap(find.text('Learning video 2'));
    await tester.pump();

    expect(
      find.textContaining('এই ভিডিওটি review gate পাস করেছে'),
      findsOneWidget,
    );
  });

  testWidgets('search filters video records', (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.enterText(find.byType(TextField), 'English Alphabet');
    await tester.pump();

    expect(find.text('English Alphabet A to Z'), findsOneWidget);
    expect(find.text('বাংলা স্বরবর্ণ শেখা'), findsNothing);
  });

  testWidgets('search also matches exact video IDs', (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.enterText(find.byType(TextField), 'TVideo00000');
    await tester.pumpAndSettle();

    expect(find.text('English Alphabet A to Z'), findsOneWidget);
    expect(find.text('বাংলা স্বরবর্ণ শেখা'), findsNothing);
  });

  testWidgets('pending video opens safety notice, not a player', (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.tap(find.text('English Alphabet A to Z'));
    await tester.pump();

    expect(
      find.textContaining('এই ভিডিওটি এখনো শিশুদের জন্য আলাদাভাবে যাচাই করা হয়নি।'),
      findsOneWidget,
    );
    expect(find.byType(VideoLibraryScreen), findsOneWidget);
  });

  testWidgets('bookmarks are stored locally', (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.tap(find.byTooltip('পরে দেখার জন্য সেভ করুন').first);
    await tester.pump();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('video_library_saved_ids'), isNotEmpty);
  });

  testWidgets('load more reveals the next page without rendering all records',
      (tester) async {
    await _pumpVideoLibrary(tester);

    expect(find.text('English Alphabet A to Z'), findsOneWidget);
    expect(find.text('Learning video 20'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    final loadMore = find.text('আরও ২০টি দেখুন');
    expect(loadMore, findsOneWidget);
    await tester.tap(loadMore);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(find.text('Learning video 20'), findsOneWidget);
  });
}
