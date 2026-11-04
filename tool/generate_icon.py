from PIL import Image, ImageDraw
from pathlib import Path

# Bright, child-friendly launcher mark: an open multicolour book and a little star.
SIZE = 1024
out = Path("assets/icon")
out.mkdir(parents=True, exist_ok=True)

# Full-bleed icon for Windows and platforms that use a single image.
base = Image.new("RGB", (SIZE, SIZE), (20, 184, 79))
d = ImageDraw.Draw(base)
for y in range(SIZE):
    t = y / SIZE
    color = (int(18 + 18*t), int(181 + 36*t), int(78 + 12*t))
    d.line((0, y, SIZE, y), fill=color)
d.ellipse((70, 70, 954, 954), fill=(255, 222, 76), outline=(255,255,255), width=20)
d.ellipse((112, 112, 912, 912), fill=(25, 183, 87))
# Book shadow
d.rounded_rectangle((170, 360, 512, 790), radius=65, fill=(8, 103, 62))
d.rounded_rectangle((512, 360, 854, 790), radius=65, fill=(8, 103, 62))
# Left and right book pages
d.polygon([(174, 325), (490, 365), (490, 770), (174, 720)], fill=(255,255,255))
d.polygon([(534, 365), (850, 325), (850, 720), (534, 770)], fill=(255,250,226))
d.line((512, 360, 512, 778), fill=(255, 190, 55), width=20)
# Colourful lesson lines
for x0, x1, y, color in [
    (230, 435, 465, (239, 83, 80)), (230, 435, 540, (255, 177, 45)),
    (230, 435, 615, (44, 154, 226)), (589, 794, 465, (65, 181, 104)),
    (589, 794, 540, (44, 154, 226)), (589, 794, 615, (239, 83, 80))
]:
    d.rounded_rectangle((x0, y, x1, y+23), radius=12, fill=color)
# Friendly golden star above the book
star = []
import math
for i in range(10):
    radius = 100 if i % 2 == 0 else 45
    angle = -math.pi/2 + i*math.pi/5
    star.append((512 + math.cos(angle)*radius, 205 + math.sin(angle)*radius))
d.polygon(star, fill=(255, 196, 43), outline=(255,255,255))
base.save(out / "app_icon.png")

# Transparent foreground for Android adaptive icons; background is configured separately.
fg = Image.new("RGBA", (SIZE, SIZE), (0,0,0,0))
fd = ImageDraw.Draw(fg)
fd.rounded_rectangle((155, 360, 505, 795), radius=62, fill=(255,255,255), outline=(11,100,61), width=12)
fd.rounded_rectangle((519, 360, 869, 795), radius=62, fill=(255,250,226), outline=(11,100,61), width=12)
fd.polygon([(170, 380), (490, 410), (490, 775), (170, 720)], fill=(255,255,255))
fd.polygon([(534, 410), (854, 380), (854, 720), (534, 775)], fill=(255,250,226))
fd.line((512, 405, 512, 790), fill=(255,190,55), width=22)
for x0, x1, y, color in [
    (225, 435, 495, (239,83,80)), (225,435,575,(255,177,45)),
    (225,435,655,(44,154,226)), (589,799,495,(65,181,104)),
    (589,799,575,(44,154,226)), (589,799,655,(239,83,80))
]:
    fd.rounded_rectangle((x0,y,x1,y+24), radius=12, fill=color)
star = []
for i in range(10):
    radius = 105 if i % 2 == 0 else 48
    angle = -math.pi/2 + i*math.pi/5
    star.append((512 + math.cos(angle)*radius, 205 + math.sin(angle)*radius))
fd.polygon(star, fill=(255,196,43), outline=(255,255,255))
fg.save(out / "app_icon_foreground.png")
print("Generated colourful Chotto Pathshala launcher icons.")
