#!/usr/bin/env python3
"""Configure a generated Flutter Android project for a Play Store AAB build."""
from __future__ import annotations

import re
from pathlib import Path

APPLICATION_ID = "com.ntech.chotto_pathshala"
TARGET_API = 36

KOTLIN_RELEASE_BLOCK = """    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

"""
GROOVY_RELEASE_BLOCK = """    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

"""


def replace_one(pattern: str, replacement: str, content: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, content, count=1, flags=re.MULTILINE)
    if count != 1:
        raise RuntimeError(f"Could not configure Android {label}; Flutter's generated Gradle template changed.")
    return updated


def configure_kotlin(path: Path) -> None:
    content = path.read_text(encoding="utf-8")
    imports = "import java.io.FileInputStream\nimport java.util.Properties\n\n"
    if "val keystoreProperties = Properties()" not in content:
        content = imports + content
        content = content.replace(
            "plugins {",
            """val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

plugins {""",
            1,
        )
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
    if "create(\"release\")" not in content:
        content = replace_one(
            r'(?m)^\s*buildTypes\s*\{',
            "    " + KOTLIN_RELEASE_BLOCK + "    buildTypes {",
            content,
            "release signing configuration",
        )
    debug_signing = r'(?m)^(\s*)signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)\s*$'
    content, count = re.subn(
        debug_signing,
        r'\1signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else null',
        content,
        count=1,
    )
    if count == 0:
        content = replace_one(
            r'(?m)^(\s*release\s*\{)',
            r'\1\n            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else null',
            content,
            "release signing switch",
        )
    path.write_text(content, encoding="utf-8")


def configure_groovy(path: Path) -> None:
    content = path.read_text(encoding="utf-8")
    if "def keystoreProperties = new Properties()" not in content:
        content = (
            "import java.io.FileInputStream\nimport java.util.Properties\n\n"
            + """def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

"""
            + content
        )
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
    if "release {" not in content:
        raise RuntimeError("Could not locate the release build type in app/build.gradle.")
    if "signingConfigs {" not in content:
        content = replace_one(
            r'(?m)^\s*buildTypes\s*\{',
            GROOVY_RELEASE_BLOCK + "    buildTypes {",
            content,
            "release signing configuration",
        )
    content, count = re.subn(
        r'(?m)^(\s*)signingConfig\s+signingConfigs\.debug\s*$',
        r'\1signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : null',
        content,
        count=1,
    )
    if count == 0:
        content = replace_one(
            r'(?m)^(\s*release\s*\{)',
            r'\1\n            signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : null',
            content,
            "release signing switch",
        )
    path.write_text(content, encoding="utf-8")


def main() -> None:
    kotlin = Path("android/app/build.gradle.kts")
    groovy = Path("android/app/build.gradle")
    if kotlin.exists():
        configure_kotlin(kotlin)
    elif groovy.exists():
        configure_groovy(groovy)
    else:
        raise FileNotFoundError("Generated Android app Gradle file was not found.")

    print(f"Android application ID: {APPLICATION_ID}")
    print(f"Minimum Google Play target API: {TARGET_API}")
    print("Release signing uses android/key.properties when present; otherwise the bundle is unsigned.")


if __name__ == "__main__":
    main()
