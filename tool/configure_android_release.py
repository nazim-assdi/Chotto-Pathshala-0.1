#!/usr/bin/env python3
"""Configure a generated Flutter Android project for a Google Play AAB build."""
from __future__ import annotations

import re
from pathlib import Path

APPLICATION_ID = "com.ntech.chotto_pathshala"
TARGET_API = 36


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


def configure_kotlin(path: Path) -> None:
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
            '            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }\n'
            '            storePassword = keystoreProperties.getProperty("storePassword")\n'
            "        }\n"
            "    }\n\n"
            r'\1buildTypes {',
            content,
            "release signing configuration",
        )

    content, count = re.subn(
        r'(?m)^(\s*)signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)\s*$',
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
            "            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null\n"
            "            storePassword keystoreProperties['storePassword']\n"
            "        }\n"
            "    }\n\n"
            r'\1buildTypes {',
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
    print("Release signing uses android/key.properties when present; without it the bundle is unsigned.")


if __name__ == "__main__":
    main()
