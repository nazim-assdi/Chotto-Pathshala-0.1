import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotto_pathshala/main.dart';

void main() {
  test('all planned learning levels are available', () {
    expect(levels.keys, containsAll(['playgroup', 'nursery', 'kg', 'class-one', 'class-two']));
  });

  test('Flutter app has the approved Bengali brand', () {
    expect(const ChottoPathshalaApp(), isA<ChottoPathshalaApp>());
  });

  testWidgets('word gallery offers Bangla, English, Arabic and math 1-10', (tester) async {
    await tester.view.setPhysicalSize(const Size(1200, 1800));
    await tester.view.setDevicePixelRatio(1);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: WordGallery()))));
    expect(find.text('বাংলা'), findsWidgets);
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

    await tester.tap(find.text('গণিত ১–১০'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Ten'), findsOneWidget);
    await tester.view.resetPhysicalSize();
  });
}
