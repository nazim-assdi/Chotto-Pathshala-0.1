#!/usr/bin/env python3
"""Fail the Play release preflight if child-safety network components return."""
from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

BLOCKED_DEPENDENCIES = {
    "http",
    "xml",
    "youtube_player_iframe",
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
    "YoutubePlayerController",
    "www.youtube.com/feeds",
    "youtube_player_iframe",
    "desktop_webview_window",
    "google_mobile_ads",
    "MobileAds.initialize",
    "FirebaseAnalytics",
    "FirebaseCrashlytics",
)
BLOCKED_PERMISSIONS = {
    "android.permission.INTERNET",
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
    errors: list[str] = []
    pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
    dependencies_text = pubspec.split("dev_dependencies:", 1)[0]
    for name in sorted(BLOCKED_DEPENDENCIES):
        if re.search(rf"(?m)^  {re.escape(name)}\s*:", dependencies_text):
            errors.append(f"Blocked dependency is present: {name}")

    for source in Path("lib").rglob("*.dart"):
        content = source.read_text(encoding="utf-8")
        for marker in BLOCKED_SOURCE_MARKERS:
            if marker in content:
                errors.append(f"Blocked source marker {marker!r} found in {source}")

    manifest_path = Path("android/app/src/main/AndroidManifest.xml")
    if not manifest_path.is_file():
        errors.append(f"Android manifest not found: {manifest_path}")
    else:
        root = ET.parse(manifest_path).getroot()
        for element in root:
            if element.tag not in {"uses-permission", "uses-permission-sdk-23"}:
                continue
            name = element.attrib.get(ANDROID_NS + "name", "")
            if name in BLOCKED_PERMISSIONS:
                errors.append(f"Unnecessary/sensitive Android permission remains: {name}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)

    print("Child-safety preflight passed: no video/network player dependency or blocked Android permission found.")


if __name__ == "__main__":
    main()
