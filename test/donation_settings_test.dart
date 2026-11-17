import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/main.dart';
import 'package:chotto_pathshala/privacy_policy_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguageController.selected.value = 'বাংলা';
  });

  testWidgets('Settings links to the in-app privacy policy and keeps N Tech footer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Developer: N Tech'), findsOneWidget);
    expect(find.text('🔐 গোপনীয়তা'), findsOneWidget);
    expect(find.textContaining('bKash'), findsNothing);
    expect(find.textContaining('Dutch-Bangla Bank'), findsNothing);
    expect(find.textContaining('Account number'), findsNothing);

    await tester.tap(find.text('🔐 গোপনীয়তা'));
    await tester.pumpAndSettle();
    expect(find.text('গোপনীয়তা নীতি'), findsOneWidget);
    expect(find.textContaining('শুধু এই ডিভাইসে স্থানীয়ভাবে সংরক্ষিত'), findsOneWidget);
  });

  testWidgets('Privacy screen follows the selected English UI language', (
    tester,
  ) async {
    AppLanguageController.selected.value = 'English';
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('What we store'), findsOneWidget);
    expect(find.text('Internet and videos'), findsOneWidget);
  });

  testWidgets('Home screen does not show the developer credit', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LearningHomeShell()));
    await tester.pump();

    expect(find.text(appDisplayName), findsOneWidget);
    expect(find.textContaining('Developer: N Tech'), findsNothing);
  });
}
