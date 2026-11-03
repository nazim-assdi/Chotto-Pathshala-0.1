from PIL import Image, ImageDraw
from pathlib import Path

# Child-friendly open-book icon for ছোট্ট পাঠশালা.
size = 1024
img = Image.new("RGBA", (size, size), (39, 112, 91, 255))
draw = ImageDraw.Draw(img)
draw.ellipse((72, 72, 952, 952), fill=(51, 137, 108, 255))
draw.rounded_rectangle((180, 275, 500, 745), radius=48, fill=(255, 250, 224, 255))
draw.rounded_rectangle((524, 275, 844, 745), radius=48, fill=(255, 250, 224, 255))
draw.polygon([(180, 300), (500, 330), (500, 745), (180, 700)], fill=(255, 255, 245, 255))
draw.polygon([(524, 330), (844, 300), (844, 700), (524, 745)], fill=(255, 255, 245, 255))
draw.line((512, 322, 512, 744), fill=(222, 166, 64, 255), width=18)
for y in (430, 510, 590):
    draw.rounded_rectangle((245, y, 445, y + 18), radius=9, fill=(83, 145, 121, 255))
    draw.rounded_rectangle((579, y, 779, y + 18), radius=9, fill=(83, 145, 121, 255))
draw.polygon([(512, 120), (540, 184), (610, 190), (558, 235), (575, 305),
              (512, 267), (449, 305), (466, 235), (414, 190), (484, 184)],
             fill=(255, 204, 83, 255))
output = Path("assets/icon/app_icon.png")
output.parent.mkdir(parents=True, exist_ok=True)
img.save(output)
print(f"Generated {output}")
