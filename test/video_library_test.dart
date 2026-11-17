import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/video_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguageController.selected.value = 'বাংলা';
  });

  test('video catalogue is designed for 1,000 records without inventing videos', () async {
    final items = await VideoLibraryRepository().load();

    expect(videoLibraryTargetCount, 1000);
    expect(videoLibraryPageSize, 20);
    expect(items.length, 25);
    expect(items.map((item) => item.videoId).toSet().length, 25);
    expect(items.every((item) => item.reviewStatus == 'PENDING_REVIEW'), isTrue);
    expect(items.any((item) => item.isApproved), isFalse);
    expect(videoLibraryAvailableForChildren, isFalse);
  });

  testWidgets('video library shows search, categories and real review counts', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VideoLibraryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ভিডিও শেখার জগৎ'), findsOneWidget);
    expect(find.text('ভিডিও বা বিষয় খুঁজুন...'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('English Alphabet A to Z'), findsOneWidget);
    expect(find.text('বাংলা স্বরবর্ণ শেখা'), findsOneWidget);
  });

  testWidgets('search filters video records', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VideoLibraryScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'English Alphabet');
    await tester.pumpAndSettle();

    expect(find.text('English Alphabet A to Z'), findsOneWidget);
    expect(find.text('বাংলা স্বরবর্ণ শেখা'), findsNothing);
  });

  testWidgets('pending video opens safety notice, not a player', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VideoLibraryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English Alphabet A to Z'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('এই ভিডিওটি এখনো শিশুদের জন্য আলাদাভাবে যাচাই করা হয়নি।'),
      findsOneWidget,
    );
    expect(find.byType(VideoLibraryScreen), findsOneWidget);
  });

  testWidgets('bookmarks are stored locally', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VideoLibraryScreen()));
    await tester.pumpAndSettle();

    final saveButton = find.byTooltip('পরে দেখার জন্য সেভ করুন').first;
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('video_library_saved_ids'), isNotEmpty);
  });
}
