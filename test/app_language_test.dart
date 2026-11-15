import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotto_pathshala/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguageController.selected.value = 'বাংলা';
  });

  test('language selection persists and updates shared locale state', () async {
    await AppLanguageController.setLanguage('English');
    expect(AppLanguageController.selected.value, 'English');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('setting_language'), 'English');

    await AppLanguageController.setLanguage('العربية');
    expect(AppLanguageController.selected.value, 'العربية');
    expect(prefs.getString('setting_language'), 'العربية');
  });

  test('UI phrase catalogue returns the selected language', () async {
    expect(appText('হোম', 'Home', 'الرئيسية'), 'হোম');
    await AppLanguageController.setLanguage('English');
    expect(appText('হোম', 'Home', 'الرئيسية'), 'Home');
    await AppLanguageController.setLanguage('العربية');
    expect(appText('হোম', 'Home', 'الرئيسية'), 'الرئيسية');
  });
}
