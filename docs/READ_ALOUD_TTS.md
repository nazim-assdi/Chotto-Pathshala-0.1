# Read Aloud — online neural API with device fallback

Release version: 1.3.9+15  
Branch: `feature/advanced-learning`

## Playback order

Reading Mode follows this order when **Try online voice API first** is enabled:

1. The app sends the selected built-in lesson section, locale, rate and pitch to the keyless Edge-TTS MCP endpoint.
2. The service returns an MP3 URL and the app plays it with `audioplayers`.
3. If the API request, network, MCP handshake, returned URL, audio download or MP3 playback fails, the app stops the remote player and uses `flutter_tts` on the device instead.
4. The next section is attempted using the same online-first/fallback order.

When the switch is disabled, the app skips network speech and uses device TTS directly. The switch preference is stored locally as `reading_online_tts_enabled` and defaults to enabled to match the requested online-first behaviour.

## Online endpoint and voices

The current no-key demo endpoint is:

`https://tts.vurthex.com/mcp`

It is an unauthenticated, third-party public demonstration of the open-source [TtsMcpServer](https://github.com/ismailcembabaoglu/ttsmcpserver), which uses Edge-TTS. The client uses MCP Streamable HTTP (`initialize`, `notifications/initialized`, then `tools/call` for `text_to_speech`), not a custom REST endpoint.

| Lesson voice locale | Edge neural voice |
|---|---|
| Bangla (`bn-BD`) | `bn-BD-NabanitaNeural` |
| English (`en-US`) | `en-US-AriaNeural` |
| Arabic (`ar-SA`) | `ar-SA-ZariyahNeural` |

The reader's speech-rate setting is translated to an Edge-TTS rate offset; its normal value maps to `+0%`.

## Privacy and limits

- No API key is embedded in the app or required by this public demo.
- The selected lesson text is sent to the third-party voice service when online mode is enabled. The request also carries language, speaking rate and normal network metadata such as IP address.
- The provider's public README says generated audio files are deleted automatically after 24 hours. This is the provider's stated policy, not a service guarantee independently controlled by Chotto Pathshala.
- The endpoint is unauthenticated and offered on a best-effort basis. It may be unavailable, rate-limited, changed or discontinued. Do not send personal/private text to it.
- The web build can encounter browser CORS or audio-host restrictions. Such failures are caught and trigger device TTS.
- Device TTS availability and voice quality depend on the operating system and installed language voices. The selected system voice may itself call an OS/vendor online service.

Parents can disable the online option in the Reading Mode screen. The public privacy page and in-app Privacy screen describe the online text transfer and fallback.

## Implementation and tests

- `lib/online_tts_client.dart`: MCP handshake, neural voice mapping, rate mapping, SSE/JSON-RPC response parsing and trusted MP3 URL validation.
- `lib/main.dart`: online playback attempt, player-error/timeout handling, automatic device-TTS fallback, Stop handling and source status.
- `test/online_tts_client_test.dart`: MCP handshake, request payload, locales/rate mapping, URL host validation and blank-text guard.
- `test/voice_coach_test.dart`: online API HTTP failure automatically selects device TTS, and device-only mode sends no network request.
- `audioplayers`: cross-platform MP3 playback for Android, iOS, Linux, macOS, Windows and web.

The tests use a mocked HTTP client; they verify the API-failure-to-device fallback path but do not certify live endpoint availability, pronunciation quality or physical-device audio latency. Those still require live-network and real Android/iOS/desktop hardware testing.

## Official project reference

- [TtsMcpServer source and demo limitations](https://github.com/ismailcembabaoglu/ttsmcpserver)
- [audioplayers package and supported platforms](https://pub.dev/packages/audioplayers)
