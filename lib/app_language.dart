import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide language preference and small UI phrase catalogue.
/// Lesson content remains in its authored language unless translated content is provided.
class AppLanguageController {
  static final ValueNotifier<String> selected = ValueNotifier<String>('বাংলা');

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('setting_language') ?? 'বাংলা';
    selected.value = const ['বাংলা', 'English', 'العربية'].contains(saved) ? saved : 'বাংলা';
  }

  static Future<void> setLanguage(String value) async {
    if (!const ['বাংলা', 'English', 'العربية'].contains(value)) return;
    selected.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_language', value);
  }

  static bool get isArabic => selected.value == 'العربية';
}

String appText(String bangla, [String? english, String? arabic]) {
  switch (AppLanguageController.selected.value) {
    case 'English': return english ?? bangla;
    case 'العربية': return arabic ?? english ?? bangla;
    default: return bangla;
  }
}
