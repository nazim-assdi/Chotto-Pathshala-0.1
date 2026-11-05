#!/usr/bin/env python3
"""Apply the Bengali display name to generated Flutter platform projects."""
from __future__ import annotations

import plistlib
import re
from pathlib import Path

APP_NAME = "ছোট্ট পাঠশালা"
ANDROID_LABEL = "{http://schemas.android.com/apk/res/android}label"


def update_android() -> None:
    path = Path("android/app/src/main/AndroidManifest.xml")
    if not path.exists():
        return
    import xml.etree.ElementTree as ET

    tree = ET.parse(path)
    application = tree.getroot().find("application")
    if application is None:
        raise RuntimeError("AndroidManifest.xml has no application element")
    application.set(ANDROID_LABEL, APP_NAME)
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
        r'(gtk_window_set_title\\s*\\(\\s*window\\s*,\\s*)"[^"]*"',
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
            r'(CreateAndShow\s*\(\s*)L"[^"]*"',
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
    print(f"Platform display names set to: {APP_NAME}")


if __name__ == "__main__":
    main()
