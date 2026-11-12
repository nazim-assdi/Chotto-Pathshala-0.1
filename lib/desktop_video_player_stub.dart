bool get hasDesktopVideoPlayer => false;

Future<void> openDesktopVideoPlayer({
  required String videoId,
  required String title,
}) async {
  throw UnsupportedError('Desktop video playback is not available on this platform.');
}
