#!/usr/bin/env python3
"""Verify the gated YouTube player and reject unrelated tracking or sensitive permissions."""
from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

BLOCKED_DEPENDENCIES = {
    "desktop_webview_window",
    "google_mobile_ads",
    "firebase_analytics",
    "firebase_crashlytics",
    "firebase_core",
    "appsflyer_sdk",
    "adjust_sdk",
    "facebook_app_events",
}
BLOCKED_SOURCE_MARKERS = (
    "desktop_webview_window",
    "google_mobile_ads",
    "MobileAds.initialize",
    "FirebaseAnalytics",
    "FirebaseCrashlytics",
)
BLOCKED_PERMISSIONS = {
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.ACCESS_WIFI_STATE",
    "com.google.android.gms.permission.AD_ID",
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.ACCESS_BACKGROUND_LOCATION",
    "android.permission.READ_PHONE_STATE",
    "android.permission.READ_PHONE_NUMBERS",
    "android.permission.CAMERA",
    "android.permission.RECORD_AUDIO",
    "android.permission.READ_CONTACTS",
    "android.permission.WRITE_CONTACTS",
    "android.permission.READ_SMS",
    "android.permission.RECEIVE_SMS",
}
ANDROID_NS = "{http://schemas.android.com/apk/res/android}"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--require-merged", action="store_true", help="Require and validate a Gradle merged release manifest")
    args = parser.parse_args()
    errors: list[str] = []
    pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
    dependencies_text = pubspec.split("dev_dependencies:", 1)[0]
    for required in ("youtube_player_iframe", "url_launcher", "http", "xml", "audioplayers", "flutter_tts"):
        if not re.search(rf"(?m)^  {re.escape(required)}\s*:", dependencies_text):
            errors.append(f"Required playback dependency is missing: {required}")
    for name in sorted(BLOCKED_DEPENDENCIES):
        if re.search(rf"(?m)^  {re.escape(name)}\s*:", dependencies_text):
            errors.append(f"Blocked dependency is present: {name}")

    for source in Path("lib").rglob("*.dart"):
        content = source.read_text(encoding="utf-8")
        for marker in BLOCKED_SOURCE_MARKERS:
            if marker in content:
                errors.append(f"Blocked source marker {marker!r} found in {source}")

    reader_source_path = Path("lib/main.dart")
    online_tts_path = Path("lib/online_tts_client.dart")
    if not online_tts_path.is_file():
        errors.append("Online TTS client is missing; cannot verify the API fallback path.")
    if not reader_source_path.is_file():
        errors.append("Main reader source is missing; cannot verify the TTS fallback path.")
    else:
        reader_source = reader_source_path.read_text(encoding="utf-8")
        for marker in (
            "tryOnline: _onlineVoiceFirst",
            "readingSource.value = 'device'",
            "await _tts.speak(text)",
            "reading_online_tts_enabled",
        ):
            if marker not in reader_source:
                errors.append(f"Read Aloud online/device fallback safeguard is missing: {marker}")

    video_library_path = Path("lib/video_library.dart")
    if video_library_path.is_file():
        video_library = video_library_path.read_text(encoding="utf-8")
        if "YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED" not in video_library or "defaultValue: false" not in video_library:
            errors.append("Video playback must use the false-by-default child-directed client build gate.")
        if "item.canPlayForChildren" not in video_library:
            errors.append("Video cards must check both per-video approval and the global child-directed client gate.")
        for marker in ("videoFeedSources", "parseYouTubeAtomFeed", "PENDING_REVIEW", "asPendingCandidate()"):
            if marker not in video_library:
                errors.append(f"Candidate-only video discovery safeguard is missing: {marker}")
        if "_refreshChannelFeeds();" in video_library:
            errors.append("Channel feeds must not refresh automatically during screen startup.")
    else:
        errors.append("Video library source is missing; cannot verify the playback gate.")

    player_path = Path("lib/video_player_screen.dart")
    if not player_path.is_file():
        errors.append("The guarded video player screen is missing.")
    else:
        player_source = player_path.read_text(encoding="utf-8")
        for marker in ("YoutubePlayerController.fromVideoId", "privacyEnhancedMode: true", "showControls: true", "autoPlay: false"):
            if marker not in player_source:
                errors.append(f"Required user-initiated YouTube player configuration missing: {marker}")

    manifest_path = Path("android/app/src/main/AndroidManifest.xml")
    manifests: list[Path] = []
    if not manifest_path.is_file():
        errors.append(f"Android manifest not found: {manifest_path}")
    else:
        manifests.append(manifest_path)

    intermediates = Path("build/app/intermediates")
    if intermediates.is_dir():
        for candidate in intermediates.rglob("AndroidManifest.xml"):
            if any("merged" in part.lower() for part in candidate.parts):
                manifests.append(candidate)

    merged_manifests = [path for path in manifests if "merged" in str(path).lower()]
    if args.require_merged and not merged_manifests:
        errors.append("No Gradle merged release manifest found after the AAB build.")

    for path in manifests:
        try:
            root = ET.parse(path).getroot()
        except ET.ParseError as error:
            errors.append(f"Could not parse Android manifest {path}: {error}")
            continue
        application = root.find("application")
        if application is None:
            errors.append(f"Android application element is missing in {path}")
        elif application.attrib.get(ANDROID_NS + "allowBackup", "").lower() != "false":
            errors.append(f"Android app data backup is not disabled in {path}")
        elif application.attrib.get(ANDROID_NS + "usesCleartextTraffic", "").lower() != "false":
            errors.append(f"Cleartext traffic is not disabled in {path}")

        permission_names = {
            element.attrib.get(ANDROID_NS + "name", "")
            for element in root
            if element.tag in {"uses-permission", "uses-permission-sdk-23"}
        }
        if "android.permission.INTERNET" not in permission_names:
            errors.append(f"Android Internet permission required by the player is missing in {path}")
        for name in permission_names:
            if name in BLOCKED_PERMISSIONS:
                errors.append(f"Unnecessary/sensitive Android permission remains in {path}: {name}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)

    print("Child-safety preflight passed: user-initiated privacy-enhanced player is gated; only INTERNET is allowed for playback.")


if __name__ == "__main__":
    main()
