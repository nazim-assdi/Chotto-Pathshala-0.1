import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/video_library.dart';

void main() {
  test('child video library remains disabled until individual review is complete', () {
    expect(videoLibraryAvailableForChildren, isFalse);
  });

  testWidgets('video tab explains that unreviewed videos are unavailable', (tester) async {
    AppLanguageController.selected.value = 'বাংলা';
    await tester.pumpWidget(const MaterialApp(home: VideoLibraryScreen()));

    expect(find.text('ভিডিও বিভাগ সাময়িকভাবে বন্ধ'), findsOneWidget);
    expect(
      find.textContaining('প্রতিটি ভিডিও আলাদাভাবে যাচাই'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
  });

  testWidgets('video safety notice is available in English', (tester) async {
    AppLanguageController.selected.value = 'English';
    await tester.pumpWidget(const MaterialApp(home: VideoLibraryScreen()));

    expect(find.text('Videos are temporarily unavailable'), findsOneWidget);
    expect(find.textContaining('individually reviewed'), findsOneWidget);
  });
}
