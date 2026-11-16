import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotto_pathshala/app_language.dart';
import 'package:chotto_pathshala/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguageController.selected.value = 'বাংলা';
  });

  testWidgets('Settings displays donation details and N Tech footer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('bKash Personal'), findsOneWidget);
    expect(find.text('+8801602859957'), findsOneWidget);
    expect(find.text('Dutch-Bangla Bank'), findsOneWidget);
    expect(find.text('Md. Nazimuddin'), findsOneWidget);
    expect(find.text('Ibrahimpur Branch'), findsOneWidget);
    expect(find.text('3001030620034'), findsOneWidget);
    expect(find.text('N Tech'), findsOneWidget);
    expect(find.byTooltip('কপি করুন'), findsNWidgets(4));
    expect(find.textContaining('ডেভেলপার: N Tech'), findsOneWidget);
  });

  testWidgets('Donation details follow the selected English UI language', (
    tester,
  ) async {
    AppLanguageController.selected.value = 'English';
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('🤍 Support Chotto Pathshala'), findsOneWidget);
    expect(find.text('Personal number'), findsOneWidget);
    expect(find.text('Account holder'), findsOneWidget);
    expect(find.text('Branch'), findsOneWidget);
    expect(find.text('Account number'), findsOneWidget);
    expect(find.text('N Tech'), findsOneWidget);
    expect(find.textContaining('Developer: N Tech'), findsOneWidget);
    expect(find.byTooltip('Copy'), findsNWidgets(4));
  });
  testWidgets('Home screen displays Chotto Pathshala and N Tech developer credit', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LearningHomeShell()));
    await tester.pump();

    expect(find.text(appDisplayName), findsOneWidget);
  });

}

