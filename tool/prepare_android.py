from pathlib import Path

manifest = Path("android/app/src/main/AndroidManifest.xml")
if not manifest.is_file():
    raise SystemExit(f"Android manifest not found: {manifest}")
source = manifest.read_text(encoding="utf-8")
permission = '    <uses-permission android:name="android.permission.INTERNET" />\n'
if "android.permission.INTERNET" not in source:
    source = source.replace("<application", permission + "    <application", 1)
queries = """    <queries>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE" />
        </intent>
    </queries>
"""
if "<queries>" not in source:
    source = source.replace("<application", queries + "    <application", 1)
source = source.replace('android:label="chotto_pathshala"', 'android:label="ছোট্ট পাঠশালা"')
manifest.write_text(source, encoding="utf-8")
print("Android INTERNET permission, TTS package visibility and Bengali app label checked.")
