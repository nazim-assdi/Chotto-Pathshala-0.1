import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'learning_data.dart';

/// English words first try the free Dictionary API audio pronunciation.
/// Bengali and Arabic use the voice packages installed on the device.
class SpeechService {
  static bool enabled = true;
  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> speak(LearningItem item, {bool letterOnly = false}) async {
    if (!enabled) return;
    if (!letterOnly && item.language == 'en') {
      final played = await _playEnglishAudio(item.word);
      if (played) return;
    }
    final text = letterOnly
        ? (item.language == 'en' ? item.glyph.split(' ').first : item.glyph)
        : item.word;
    await _speakText(text, item.language);
  }

  static Future<bool> _playEnglishAudio(String word) async {
    try {
      final uri = Uri.https(
        'api.dictionaryapi.dev',
        '/api/v2/entries/en/${Uri.encodeComponent(word.toLowerCase())}',
      );
      final response = await http.get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty || decoded.first is! Map) return false;
      final entry = decoded.first as Map<String, dynamic>;
      final phonetics = entry['phonetics'];
      if (phonetics is! List) return false;
      for (final item in phonetics) {
        if (item is! Map) continue;
        final raw = (item['audio'] ?? '').toString().trim();
        if (raw.isEmpty) continue;
        final audioUrl = raw.startsWith('//') ? 'https:$raw' : raw;
        try {
          await _player.stop();
          await _player.play(UrlSource(audioUrl));
          return true;
        } catch (_) {
          // Continue to the device TTS fallback.
        }
      }
    } catch (_) {
      // No internet, API timeout, unsupported word or browser CORS: use TTS.
    }
    return false;
  }

  static Future<void> _speakText(String text, String language) async {
    try {
      final locale = switch (language) {
        'bn' => 'bn-BD',
        'ar' => 'ar-SA',
        _ => 'en-US',
      };
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(.42);
      await _tts.setPitch(1.08);
      await _tts.setVolume(1.0);
      await _tts.speak(text);
    } catch (_) {
      // The selected language voice may not be installed on this device.
    }
  }

  static Future<void> sayBangla(String text) async {
    if (!enabled) return;
    await _speakText(text, 'bn');
  }

  static Future<void> stop() async {
    await _tts.stop();
    await _player.stop();
  }
}
