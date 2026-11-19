#!/usr/bin/env python3
"""Configure a generated Flutter Android project for a Google Play AAB build."""
from __future__ import annotations

import re
import xml.etree.ElementTree as ET
from pathlib import Path

APPLICATION_ID = "com.ntech.chotto_pathshala"
TARGET_API = 36



ANDROID_NS = "{http://schemas.android.com/apk/res/android}"
REMOVED_PERMISSIONS = {
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


def strip_unneeded_permissions(manifest: Path) -> None:
    """Keep the child-facing Android app offline and remove unnecessary sensitive permissions."""
    tree = ET.parse(manifest)
    root = tree.getroot()
    removed = []
    for element in list(root):
        if element.tag not in {"uses-permission", "uses-permission-sdk-23"}:
            continue
        name = element.attrib.get(ANDROID_NS + "name", "")
        if name in REMOVED_PERMISSIONS:
            root.remove(element)
            removed.append(name)

    application = root.find("application")
    if application is None:
        raise RuntimeError("Android application element is missing.")
    application.set(ANDROID_NS + "allowBackup", "false")
    application.set(ANDROID_NS + "usesCleartextTraffic", "false")

    ET.register_namespace("android", "http://schemas.android.com/apk/res/android")
    tree.write(manifest, encoding="utf-8", xml_declaration=True)
    print("Removed Android permissions: " + (", ".join(sorted(set(removed))) if removed else "none found"))


def replace_one(pattern: str, replacement: str, content: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, content, count=1, flags=re.MULTILINE)
    if count != 1:
        raise RuntimeError(
            f"Could not configure Android {label}; Flutter's generated Gradle template changed."
        )
    return updated


def add_properties_after_plugins(content: str, block: str) -> str:
    """Keep Gradle's plugins {} block first, as required by Kotlin/Groovy DSL."""
    match = re.search(r"(?ms)^plugins\s*\{.*?^\}", content)
    if match:
        return content[:match.end()] + "\n\n" + block + content[match.end():]
    # Older Groovy templates may use apply plugin rather than a plugins block.
    match = re.search(r"(?m)^android\s*\{", content)
    if not match:
        raise RuntimeError("Could not locate the Gradle plugins or android block.")
    return content[:match.start()] + block + "\n\n" + content[match.start():]


def configure_kotlin(path: Path, debug_signing_fallback: bool = False) -> None:
    content = path.read_text(encoding="utf-8")
    if "val keystoreProperties = Properties()" not in content:
        content = "import java.io.FileInputStream\nimport java.util.Properties\n\n" + content
        properties_block = """val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}"""
        content = add_properties_after_plugins(content, properties_block)

    content = replace_one(
        r'(?m)^(\s*namespace\s*=\s*)"[^"]+"',
        rf'\1"{APPLICATION_ID}"',
        content,
        "namespace",
    )
    content = replace_one(
        r'(?m)^(\s*applicationId\s*=\s*)"[^"]+"',
        rf'\1"{APPLICATION_ID}"',
        content,
        "applicationId",
    )
    content = replace_one(
        r'(?m)^(\s*compileSdk\s*=\s*)flutter\.compileSdkVersion',
        rf'\1maxOf(flutter.compileSdkVersion, {TARGET_API})',
        content,
        "compileSdk",
    )
    content = replace_one(
        r'(?m)^(\s*targetSdk\s*=\s*)flutter\.targetSdkVersion',
        rf'\1maxOf(flutter.targetSdkVersion, {TARGET_API})',
        content,
        "targetSdk",
    )

    if 'create("release")' not in content:
        content = replace_one(
            r'(?m)^(\s*)buildTypes\s*\{',
            "    signingConfigs {\n"
            '        create("release") {\n'
            '            keyAlias = keystoreProperties.getProperty("keyAlias")\n'
            '            keyPassword = keystoreProperties.getProperty("keyPassword")\n'
            '            storeFile = keystoreProperties.getProperty("storeFile")?.let { rootProject.file(it) }\n'
            '            storePassword = keystoreProperties.getProperty("storePassword")\n'
            "        }\n"
            "    }\n\n"
            r'\1buildTypes {',
            content,
            "release signing configuration",
        )

    signing_fallback = (
        'signingConfigs.getByName("debug")'
        if debug_signing_fallback
        else "null"
    )
    signing_switch = (
        r'\1signingConfig = if (keystorePropertiesFile.exists()) '
        r'signingConfigs.getByName("release") else '
        + signing_fallback
    )
    content, count = re.subn(
        r'(?m)^(\s*)signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)\s*$',
        signing_switch,
        content,
        count=1,
    )
    if count == 0:
        content = replace_one(
            r'(?m)^(\s*release\s*\{)',
            r'\1\n            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else ' + signing_fallback,
            content,
            "release signing switch",
        )
    path.write_text(content, encoding="utf-8")


def configure_groovy(path: Path, debug_signing_fallback: bool = False) -> None:
    content = path.read_text(encoding="utf-8")
    if "def keystoreProperties = new Properties()" not in content:
        content = "import java.io.FileInputStream\nimport java.util.Properties\n\n" + content
        properties_block = """def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}"""
        content = add_properties_after_plugins(content, properties_block)

    content = replace_one(
        r'(?m)^(\s*namespace\s*(?:=\s*)?)["\'][^"\']+["\']',
        rf'\1"{APPLICATION_ID}"',
        content,
        "namespace",
    )
    content = replace_one(
        r'(?m)^(\s*applicationId\s*(?:=\s*)?)["\'][^"\']+["\']',
        rf'\1"{APPLICATION_ID}"',
        content,
        "applicationId",
    )
    content = replace_one(
        r'(?m)^(\s*compileSdkVersion\s+)flutter\.compileSdkVersion',
        rf'\1Math.max(flutter.compileSdkVersion, {TARGET_API})',
        content,
        "compileSdkVersion",
    )
    content = replace_one(
        r'(?m)^(\s*targetSdkVersion\s+)flutter\.targetSdkVersion',
        rf'\1Math.max(flutter.targetSdkVersion, {TARGET_API})',
        content,
        "targetSdkVersion",
    )

    if "signingConfigs {" not in content:
        content = replace_one(
            r'(?m)^(\s*)buildTypes\s*\{',
            "    signingConfigs {\n"
            "        release {\n"
            "            keyAlias keystoreProperties['keyAlias']\n"
            "            keyPassword keystoreProperties['keyPassword']\n"
            "            storeFile keystoreProperties['storeFile'] ? rootProject.file(keystoreProperties['storeFile']) : null\n"
            "            storePassword keystoreProperties['storePassword']\n"
            "        }\n"
            "    }\n\n"
            r'\1buildTypes {',
            content,
            "release signing configuration",
        )

    signing_fallback = "signingConfigs.debug" if debug_signing_fallback else "null"
    signing_switch = (
        r'\1signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : '
        + signing_fallback
    )
    content, count = re.subn(
        r'(?m)^(\s*)signingConfig\s+signingConfigs\.debug\s*$',
        signing_switch,
        content,
        count=1,
    )
    if count == 0:
        content = replace_one(
            r'(?m)^(\s*release\s*\{)',
            r'\1\n            signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : ' + signing_fallback,
            content,
            "release signing switch",
        )
    path.write_text(content, encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--debug-signing-fallback",
        action="store_true",
        help="Sign non-Play test APKs with the generated debug key when no upload key exists.",
    )
    args = parser.parse_args()

    kotlin = Path("android/app/build.gradle.kts")
    groovy = Path("android/app/build.gradle")
    if kotlin.exists():
        configure_kotlin(kotlin, args.debug_signing_fallback)
    elif groovy.exists():
        configure_groovy(groovy, args.debug_signing_fallback)
    else:
        raise FileNotFoundError("Generated Android app Gradle file was not found.")

    print(f"Android application ID: {APPLICATION_ID}")
    print(f"Minimum Google Play target API: {TARGET_API}")
    manifest = Path("android/app/src/main/AndroidManifest.xml")
    if not manifest.is_file():
        raise FileNotFoundError("Generated Android main manifest was not found.")
    strip_unneeded_permissions(manifest)
    print("Release signing uses android/key.properties when present; without it the bundle is unsigned.")


if __name__ == "__main__":
    main()
