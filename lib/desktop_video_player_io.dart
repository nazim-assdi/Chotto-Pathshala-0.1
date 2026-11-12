import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';

import 'desktop_video_embed.dart';

bool get hasDesktopVideoPlayer => Platform.isWindows || Platform.isLinux;

/// Opens a native WebView player window owned by the application.
Future<void> openDesktopVideoPlayer({
  required String videoId,
  required String title,
}) async {
  if (!hasDesktopVideoPlayer) {
    throw UnsupportedError('Desktop video playback is only available on Windows and Linux.');
  }
  if (Platform.isWindows && !await WebviewWindow.isWebviewAvailable()) {
    throw StateError('WEBVIEW2_RUNTIME_MISSING');
  }

  final playerUrl = await _DesktopVideoServer.playerUrl(videoId);
  final userDataFolder =
      Platform.isWindows ? await _windowsUserDataFolder() : 'webview_window_WebView2';

  final configuration = CreateConfiguration(
    windowWidth: 1120,
    windowHeight: 720,
    title: 'ছোট্ট পাঠশালা • $title',
    titleBar: const TitleBarOptions(
      showNavigation: false,
      showReload: true,
      showTitle: true,
      showHost: false,
    ),
    brightness: Brightness.dark,
    windows: WindowsWebviewOptions(userDataFolder: userDataFolder),
  );

  final webview = await WebviewWindow.create(configuration: configuration);
  await webview.setApplicationNameForUserAgent('ChottoPathshala/1.2.1');
  await webview.launch(
    playerUrl.toString(),
    triggerOnUrlRequestEvent: false,
  );
}

Future<String> _windowsUserDataFolder() async {
  final localAppData = Platform.environment['LOCALAPPDATA'];
  final basePath = localAppData == null || localAppData.isEmpty
      ? Directory.systemTemp.path
      : localAppData;
  final separator = Platform.pathSeparator;
  final folder = Directory(
    basePath + separator + 'Chotto Pathshala' + separator + 'WebView2',
  );
  await folder.create(recursive: true);
  return folder.path;
}

class _DesktopVideoServer {
  static Future<HttpServer>? _serverFuture;

  static Future<Uri> playerUrl(String videoId) async {
    if (!RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(videoId)) {
      throw const FormatException('Invalid YouTube video ID.');
    }
    final server = await _getServer();
    return Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: server.port,
      pathSegments: <String>['watch', videoId],
    );
  }

  static Future<HttpServer> _getServer() async {
    final current = _serverFuture;
    if (current != null) return current;
    final pending = _startServer();
    _serverFuture = pending;
    try {
      return await pending;
    } catch (_) {
      _serverFuture = null;
      rethrow;
    }
  }

  static Future<HttpServer> _startServer() async {
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
      shared: false,
    );
    server.listen(
      (request) => unawaited(_handleRequest(request, server.port)),
      onError: (Object error, StackTrace stackTrace) {},
    );
    return server;
  }

  static Future<void> _handleRequest(HttpRequest request, int port) async {
    final segments = request.uri.pathSegments;
    final validRequest = request.method == 'GET' &&
        segments.length == 2 &&
        segments.first == 'watch' &&
        RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(segments.last);

    if (!validRequest) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..headers.contentType = ContentType.text
        ..write('Not found');
      await request.response.close();
      return;
    }

    final origin = Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: port,
    );
    final response = request.response;
    response
      ..headers.contentType = ContentType.html
      ..headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')
      ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
      ..write(buildDesktopVideoEmbedHtml(segments.last, origin));
    await response.close();
  }
}
