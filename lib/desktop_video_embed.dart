const _youtubeVideoIdPattern = r'^[A-Za-z0-9_-]{11}$';

/// Builds a local HTML page that embeds a privacy-enhanced YouTube player.
/// The loopback HTTP origin provides the HTTP Referer required by YouTube.
String buildDesktopVideoEmbedHtml(String videoId, Uri localOrigin) {
  if (!RegExp(_youtubeVideoIdPattern).hasMatch(videoId)) {
    throw const FormatException('Invalid YouTube video ID.');
  }
  if (localOrigin.scheme != 'http' ||
      localOrigin.host != '127.0.0.1' ||
      localOrigin.port == 0) {
    throw const FormatException('A loopback HTTP origin is required.');
  }

  final origin = localOrigin.origin;
  final embedUri = Uri.https(
    'www.youtube-nocookie.com',
    '/embed/$videoId',
    <String, String>{
      'autoplay': '1',
      'controls': '1',
      'rel': '0',
      'playsinline': '1',
      'origin': origin,
      'widget_referrer': origin,
    },
  );
  final iframeSrc = embedUri.toString().replaceAll('&', '&amp;');

  return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <title>Chotto Pathshala Video Player</title>
  <style>
    html, body {
      width: 100%;
      height: 100%;
      margin: 0;
      background: #101817;
      overflow: hidden;
      font-family: Arial, sans-serif;
    }
    main {
      width: 100%;
      height: 100%;
      display: grid;
      place-items: center;
      background: radial-gradient(ellipse at center, #1b2925 0%, #101817 72%);
    }
    iframe {
      display: block;
      width: min(100vw, 1440px);
      height: min(100vh, 810px);
      aspect-ratio: 16 / 9;
      border: 0;
      background: #000;
    }
  </style>
</head>
<body>
  <main>
    <iframe
      src="$iframeSrc"
      title="ছোট্ট পাঠশালা ভিডিও"
      referrerpolicy="strict-origin-when-cross-origin"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen>
    </iframe>
  </main>
</body>
</html>
''';
}
