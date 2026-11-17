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
          subject: index == 1 ? 'বাংলা' : 'English',
          language: index == 1 ? 'বাংলা' : 'English',
          reviewStatus: 'PENDING_REVIEW',
          ageBand: '',
          madeForKidsStatus: 'NOT_CHECKED',
          rightsCheck: '',
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
        {"video_id":"TVideo00001","title":"First video","channel":"Test channel"},
        {"video_id":"TVideo00001","title":"Duplicate video","channel":"Test channel"},
        {"video_id":"not-valid","title":"Invalid ID","channel":"Test channel"},
        {"video_id":"TVideo00002","title":"Second video","channel":"Test channel"}
      ]
    }
    ''';
    final items = VideoLibraryRepository().parse(raw);

    expect(videoLibraryTargetCount, 1000);
    expect(videoLibraryPageSize, 20);
    expect(items.map((item) => item.videoId).toList(),
        ['TVideo00001', 'TVideo00002']);
    expect(items.every((item) => item.reviewStatus == 'PENDING_REVIEW'), isTrue);
    expect(items.any((item) => item.isApproved), isFalse);
    expect(videoLibraryAvailableForChildren, isFalse);
  });

  testWidgets('video library shows search, categories and truthful counters', (tester) async {
    await _pumpVideoLibrary(tester);

    expect(find.text('ভিডিও শেখার জগৎ'), findsOneWidget);
    expect(find.text('ভিডিও বা বিষয় খুঁজুন...'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('search filters video records', (tester) async {
    await _pumpVideoLibrary(tester);

    await tester.enterText(find.byType(TextField), 'English Alphabet');
    await tester.pump();

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

    expect(find.text('Learning video 19'), findsOneWidget);
    expect(find.text('Learning video 20'), findsNothing);

    await tester.tap(find.text('আরও ২০টি দেখুন'));
    await tester.pump();

    expect(find.text('Learning video 20'), findsOneWidget);
  });
}
