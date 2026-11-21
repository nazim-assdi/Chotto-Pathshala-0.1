import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:chotto_pathshala/main.dart';
import 'package:chotto_pathshala/online_tts_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await VoiceCoach.stopReading();
    VoiceCoach.resetOnlineTtsClientForTesting();
    VoiceCoach.enabled = true;
  });

  test('online API failure automatically falls back to device TTS', () async {
    var requestCount = 0;
    final mockClient = MockClient((request) async {
      requestCount++;
      return http.Response('Service unavailable', 503);
    });
    VoiceCoach.setOnlineTtsClientForTesting(
      OnlineTtsMcpClient(client: mockClient),
    );

    var completed = false;
    await VoiceCoach.speakReading(
      'একটি লাল আপেল আছে।',
      language: 'bn-BD',
      rate: 0.42,
      tryOnline: true,
      onComplete: () => completed = true,
    );

    expect(requestCount, 1);
    expect(VoiceCoach.readingSource.value, 'device');
    // Flutter widget tests have no native speech engine; the device call is
    // safely caught and the reader is still notified to continue.
    expect(completed, isTrue);
  });

  test('device-only mode skips the online API completely', () async {
    var requestCount = 0;
    final mockClient = MockClient((request) async {
      requestCount++;
      return http.Response('Unexpected network request', 500);
    });
    VoiceCoach.setOnlineTtsClientForTesting(
      OnlineTtsMcpClient(client: mockClient),
    );

    var completed = false;
    await VoiceCoach.speakReading(
      'Read offline.',
      language: 'en-US',
      rate: 0.42,
      tryOnline: false,
      onComplete: () => completed = true,
    );

    expect(requestCount, 0);
    expect(VoiceCoach.readingSource.value, 'device');
    expect(completed, isTrue);
  });
}
