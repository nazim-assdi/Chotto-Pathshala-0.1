#!/usr/bin/env python3
"""Apply the Bengali display name to generated Flutter platform projects."""
from __future__ import annotations

import plistlib
import re
from pathlib import Path

APP_NAME = "ছোট্ট পাঠশালা"
ANDROID_NS = "http://schemas.android.com/apk/res/android"
ANDROID_LABEL = f"{{{ANDROID_NS}}}label"
ANDROID_NAME = f"{{{ANDROID_NS}}}name"
ANDROID_VALUE = f"{{{ANDROID_NS}}}value"


def update_android() -> None:
    path = Path("android/app/src/main/AndroidManifest.xml")
    if not path.exists():
        return
    import xml.etree.ElementTree as ET

    ET.register_namespace("android", ANDROID_NS)
    tree = ET.parse(path)
    application = tree.getroot().find("application")
    if application is None:
        raise RuntimeError("AndroidManifest.xml has no application element")
    application.set(ANDROID_LABEL, APP_NAME)

    # Flutter 3.47+ requires the explicit V2 embedding metadata in the app manifest.
    embedding = None
    for item in application.findall("meta-data"):
        if item.get(ANDROID_NAME) == "flutterEmbedding":
            embedding = item
            break
    if embedding is None:
        embedding = ET.SubElement(application, "meta-data")
    embedding.set(ANDROID_NAME, "flutterEmbedding")
    embedding.set(ANDROID_VALUE, "2")

    tree.write(path, encoding="utf-8", xml_declaration=True)


def update_plist(path: Path) -> None:
    if not path.exists():
        return
    with path.open("rb") as stream:
        data = plistlib.load(stream)
    data["CFBundleDisplayName"] = APP_NAME
    data["CFBundleName"] = APP_NAME
    with path.open("wb") as stream:
        plistlib.dump(data, stream, fmt=plistlib.FMT_XML, sort_keys=False)


def update_linux() -> None:
    path = Path("linux/runner/my_application.cc")
    if not path.exists():
        return
    content = path.read_text(encoding="utf-8")
    content, count = re.subn(
        r'(gtk_window_set_title\s*\(\s*window\s*,\s*)"[^"]*"',
        lambda match: match.group(1) + '"' + APP_NAME + '"',
        content,
        count=1,
    )
    if count == 0:
        raise RuntimeError("Could not locate the Linux window title in my_application.cc")
    path.write_text(content, encoding="utf-8")


def update_windows() -> None:
    main_cpp = Path("windows/runner/main.cpp")
    if main_cpp.exists():
        content = main_cpp.read_text(encoding="utf-8")
        content, count = re.subn(
            r'((?:CreateAndShow|Create)\s*\(\s*)L"[^"]*"',
            lambda match: match.group(1) + 'L"' + APP_NAME + '"',
            content,
            count=1,
        )
        if count == 0:
            raise RuntimeError("Could not locate the Windows window title in main.cpp")
        main_cpp.write_text(content, encoding="utf-8")

    resource = Path("windows/runner/Runner.rc")
    if resource.exists():
        content = resource.read_text(encoding="utf-8")
        for key, value in {
            "FileDescription": APP_NAME,
            "InternalName": APP_NAME,
            "OriginalFilename": APP_NAME + ".exe",
            "ProductName": APP_NAME,
        }.items():
            pattern = r'(^\s*VALUE\s+"' + re.escape(key) + r'"\s*,\s*)"[^"]*"'
            content, count = re.subn(
                pattern,
                lambda match, v=value: match.group(1) + '"' + v + '"',
                content,
                count=1,
                flags=re.MULTILINE,
            )
            if count == 0:
                raise RuntimeError(f"Could not set Windows version resource: {key}")
        resource.write_text(content, encoding="utf-8")


def main() -> None:
    update_android()
    update_plist(Path("ios/Runner/Info.plist"))
    update_plist(Path("macos/Runner/Info.plist"))
    update_windows()
    update_linux()
    print("Platform display names set successfully.")


if __name__ == "__main__":
    main()
