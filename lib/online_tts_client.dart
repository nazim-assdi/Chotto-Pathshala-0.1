import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Keyless online text-to-speech adapter for the Reading Mode.
///
/// This uses a best-effort public Edge-TTS MCP endpoint. The app always keeps
/// device TTS as its fallback; callers must catch network/provider failures.
class OnlineTtsMcpClient {
  OnlineTtsMcpClient({
    http.Client? client,
    this.endpoint = defaultEndpoint,
  }) : _client = client ?? http.Client();

  static const String defaultEndpoint = 'https://tts.vurthex.com/mcp';
  static const String _protocolVersion = '2024-11-05';

  final http.Client _client;
  final String endpoint;
  int _requestId = 0;

  String voiceForLanguage(String language) {
    final value = language.toLowerCase();
    if (value.startsWith('bn')) return 'bn-BD-NabanitaNeural';
    if (value.startsWith('ar')) return 'ar-SA-ZariyahNeural';
    return 'en-US-AriaNeural';
  }

  String rateForSpeech(double speechRate) {
    // The reader's default rate (0.42) maps to Edge-TTS's normal +0%.
    final percent = (((speechRate - 0.42) / 0.42) * 100)
        .round()
        .clamp(-40, 60);
    return percent >= 0 ? '+$percent%' : '$percent%';
  }

  Future<Uri> synthesize({
    required String text,
    required String language,
    required double speechRate,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Text must not be empty.');
    }

    final initializeId = ++_requestId;
    final initialize = await _post(
      {
        'jsonrpc': '2.0',
        'id': initializeId,
        'method': 'initialize',
        'params': {
          'protocolVersion': _protocolVersion,
          'capabilities': <String, dynamic>{},
          'clientInfo': {
            'name': 'chotto-pathshala',
            'version': '1.3.8',
          },
        },
      },
    );
    _requireRpcSuccess(initialize.message, initializeId);
    final sessionId = initialize.sessionId;

    // Streamable HTTP requires the initialized notification after initialize.
    await _post(
      {
        'jsonrpc': '2.0',
        'method': 'notifications/initialized',
      },
      sessionId: sessionId,
      allowEmptyBody: true,
    );

    final callId = ++_requestId;
    final call = await _post(
      {
        'jsonrpc': '2.0',
        'id': callId,
        'method': 'tools/call',
        'params': {
          'name': 'text_to_speech',
          'arguments': {
            'text': cleanText,
            'voice': voiceForLanguage(language),
            'rate': rateForSpeech(speechRate),
            'pitch': '+0Hz',
          },
        },
      },
      sessionId: sessionId,
    );
    _requireRpcSuccess(call.message, callId);
    return _extractAudioUri(call.message);
  }

  Future<_McpHttpResponse> _post(
    Map<String, dynamic> body, {
    String? sessionId,
    bool allowEmptyBody = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/event-stream',
    };
    if (sessionId != null && sessionId.isNotEmpty) {
      headers['Mcp-Session-Id'] = sessionId;
    }

    final response = await _client
        .post(
          Uri.parse(endpoint),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 18));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'Online TTS endpoint returned HTTP ${response.statusCode}.',
        Uri.parse(endpoint),
      );
    }

    final session = response.headers.entries
        .where((entry) => entry.key.toLowerCase() == 'mcp-session-id')
        .map((entry) => entry.value)
        .firstOrNull;

    if (response.body.trim().isEmpty) {
      if (allowEmptyBody) {
        return _McpHttpResponse(message: const {}, sessionId: session);
      }
      throw const FormatException('Online TTS endpoint returned an empty response.');
    }

    return _McpHttpResponse(
      message: _decodeRpcMessage(response.body),
      sessionId: session,
    );
  }

  Map<String, dynamic> _decodeRpcMessage(String body) {
    final trimmed = body.trim();
    if (trimmed.startsWith('{')) {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Unexpected JSON-RPC response.');
    }

    // Streamable HTTP servers commonly send JSON-RPC messages as SSE data.
    final events = <Map<String, dynamic>>[];
    for (final event in trimmed.split(RegExp(r'\r?\n\r?\n'))) {
      final data = event
          .split(RegExp(r'\r?\n'))
          .where((line) => line.startsWith('data:'))
          .map((line) => line.substring(5).trim())
          .join('\n');
      if (data.isEmpty || data == '[DONE]') continue;
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) events.add(decoded);
      } catch (_) {
        // Ignore SSE comments/keep-alive messages and non-JSON events.
      }
    }

    if (events.isEmpty) {
      throw const FormatException('No JSON-RPC message was found in the SSE response.');
    }
    return events.last;
  }

  void _requireRpcSuccess(Map<String, dynamic> message, int expectedId) {
    if (message['id'] != expectedId) {
      throw const FormatException('Online TTS returned an unexpected request ID.');
    }
    final error = message['error'];
    if (error != null) {
      throw StateError('Online TTS RPC error: $error');
    }
    if (message['result'] is! Map) {
      throw const FormatException('Online TTS response is missing its result.');
    }
    final result = message['result'] as Map;
    if (result['isError'] == true) {
      throw StateError('Online TTS provider could not synthesize this text.');
    }
  }

  Uri _extractAudioUri(Map<String, dynamic> message) {
    final result = message['result'];
    if (result is! Map) {
      throw const FormatException('Online TTS did not return an audio result.');
    }

    final candidates = <dynamic>[
      result['structuredContent'],
      result['content'],
    ];
    for (final candidate in candidates) {
      final found = _findAudioUrl(candidate);
      if (found != null) {
        final uri = Uri.tryParse(found);
        if (uri != null &&
            uri.scheme == 'https' &&
            uri.host == 'tts.vurthex.com' &&
            uri.path.startsWith('/audio/')) {
          return uri;
        }
      }
    }
    throw const FormatException('Online TTS returned no trusted MP3 URL.');
  }

  String? _findAudioUrl(dynamic value) {
    if (value is Map) {
      final direct = value['url'];
      if (direct is String && direct.trim().isNotEmpty) return direct.trim();
      for (final item in value.values) {
        final result = _findAudioUrl(item);
        if (result != null) return result;
      }
    } else if (value is Iterable) {
      for (final item in value) {
        final result = _findAudioUrl(item);
        if (result != null) return result;
      }
    } else if (value is String) {
      try {
        final decoded = jsonDecode(value);
        final result = _findAudioUrl(decoded);
        if (result != null) return result;
      } catch (_) {
        final match = RegExp(
          r'https://tts\.vurthex\.com/audio/[A-Za-z0-9_-]+\.mp3',
        ).firstMatch(value);
        if (match != null) return match.group(0);
      }
    }
    return null;
  }

  void close() => _client.close();
}

class _McpHttpResponse {
  const _McpHttpResponse({
    required this.message,
    required this.sessionId,
  });

  final Map<String, dynamic> message;
  final String? sessionId;
}
