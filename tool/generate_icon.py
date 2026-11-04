from pathlib import Path
from PIL import Image, ImageOps

source = Path("assets/icon/app_icon.jpg")
target = Path("assets/icon/app_icon.png")
if not source.is_file():
    raise SystemExit(f"Missing icon source: {source}")
target.parent.mkdir(parents=True, exist_ok=True)
with Image.open(source) as image:
    image = ImageOps.fit(image.convert("RGB"), (1024, 1024), method=Image.Resampling.LANCZOS)
    image.save(target, format="PNG", optimize=True)
print(f"Launcher icon prepared: {target} ({target.stat().st_size:,} bytes)")
