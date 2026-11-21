import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:chotto_pathshala/online_tts_client.dart';

void main() {
  test('maps Bangla, English and Arabic to neural voice IDs', () {
    final client = OnlineTtsMcpClient(
      client: MockClient((_) async => http.Response('', 500)),
    );

    expect(client.voiceForLanguage('bn-BD'), 'bn-BD-NabanitaNeural');
    expect(client.voiceForLanguage('en-US'), 'en-US-AriaNeural');
    expect(client.voiceForLanguage('ar-SA'), 'ar-SA-ZariyahNeural');
    expect(client.rateForSpeech(0.42), '+0%');
    expect(client.rateForSpeech(0.25), '-40%');
    expect(client.rateForSpeech(0.68), '+60%');
  });

  test('performs MCP initialize, initialized notification and TTS call', () async {
    var requestCount = 0;
    final client = OnlineTtsMcpClient(
      client: MockClient((request) async {
        requestCount++;
        expect(request.url.toString(), OnlineTtsMcpClient.defaultEndpoint);
        final body = jsonDecode(request.body) as Map<String, dynamic>;

        if (requestCount == 1) {
          expect(body['method'], 'initialize');
          expect(body['id'], 1);
          return http.Response(
            'event: message\ndata: ${jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': {'protocolVersion': '2024-11-05'},
            })}\n\n',
            200,
            headers: {
              'content-type': 'text/event-stream',
              'mcp-session-id': 'test-session',
            },
          );
        }

        expect(request.headers['Mcp-Session-Id'], 'test-session');
        if (requestCount == 2) {
          expect(body['method'], 'notifications/initialized');
          return http.Response('', 202);
        }

        expect(body['method'], 'tools/call');
        expect(body['id'], 2);
        final params = body['params'] as Map<String, dynamic>;
        expect(params['name'], 'text_to_speech');
        final args = params['arguments'] as Map<String, dynamic>;
        expect(args['text'], 'একটি লাল আপেল আছে।');
        expect(args['voice'], 'bn-BD-NabanitaNeural');
        expect(args['rate'], '+0%');
        expect(args['pitch'], '+0Hz');

        return http.Response(
          'event: message\ndata: ${jsonEncode({
            'jsonrpc': '2.0',
            'id': 2,
            'result': {
              'structuredContent': {
                'url': 'https://tts.vurthex.com/audio/test123.mp3',
              },
            },
          })}\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    final audio = await client.synthesize(
      text: '  একটি লাল আপেল আছে।  ',
      language: 'bn-BD',
      speechRate: 0.42,
    );

    expect(requestCount, 3);
    expect(audio.toString(), 'https://tts.vurthex.com/audio/test123.mp3');
  });

  test('rejects an untrusted audio host from API responses', () async {
    final client = OnlineTtsMcpClient(
      client: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['method'] == 'initialize') {
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': body['id'],
              'result': {'protocolVersion': '2024-11-05'},
            }),
            200,
            headers: {'mcp-session-id': 'test-session'},
          );
        }
        if (body['method'] == 'notifications/initialized') {
          return http.Response('', 202);
        }
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': body['id'],
            'result': {
              'structuredContent': {
                'url': 'https://example.com/not-trusted.mp3',
              },
            },
          }),
          200,
        );
      }),
    );

    await expectLater(
      client.synthesize(
        text: 'hello',
        language: 'en-US',
        speechRate: 0.42,
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects blank text before sending a network request', () async {
    var requests = 0;
    final client = OnlineTtsMcpClient(
      client: MockClient((_) async {
        requests++;
        return http.Response('', 500);
      }),
    );

    await expectLater(
      client.synthesize(
        text: '   ',
        language: 'bn-BD',
        speechRate: 0.42,
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(requests, 0);
  });
}
