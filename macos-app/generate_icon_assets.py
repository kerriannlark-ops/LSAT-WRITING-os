from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parent.parent
MACOS_DIR = ROOT / "macos-app"
ICONSET_DIR = MACOS_DIR / "AppIcon.iconset"
MASTER_PATH = MACOS_DIR / "AppIcon-master.png"
ICNS_PATH = MACOS_DIR / "AppIcon.icns"


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def vertical_mix(start, end, t: float):
    return tuple(int(start[i] + (end[i] - start[i]) * t) for i in range(3))


def build_master() -> Image.Image:
    size = 1024
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    top = (22, 50, 79)
    mid = (39, 76, 115)
    bottom = (63, 103, 150)
    gradient = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gradient_draw = ImageDraw.Draw(gradient)
    for y in range(size):
        t = y / (size - 1)
        if t < 0.58:
            color = vertical_mix(top, mid, t / 0.58)
        else:
            color = vertical_mix(mid, bottom, (t - 0.58) / 0.42)
        gradient_draw.line((0, y, size, y), fill=color + (255,))

    image.paste(gradient, (0, 0), rounded_mask(size, 220))

    sparkle = ImageDraw.Draw(image)
    for x, y in ((236, 202), (292, 202), (264, 174), (264, 230)):
        sparkle.ellipse((x - 16, y - 16, x + 16, y + 16), fill=(220, 233, 247, 44))

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((232, 176, 792, 868), radius=84, fill=(11, 24, 40, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))
    image.alpha_composite(shadow)

    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((232, 162, 792, 854), radius=84, fill=(251, 247, 239, 255), outline=(223, 211, 194, 255), width=8)
    draw.polygon(((670, 162), (792, 162), (792, 284), (670, 284)), fill=(241, 233, 221, 255))
    draw.polygon(((670, 162), (792, 284), (670, 284)), fill=(231, 223, 208, 255))

    draw.rounded_rectangle((292, 244, 456, 296), radius=24, fill=(127, 75, 103, 255))
    for box in (
        (292, 340, 728, 366),
        (292, 404, 674, 430),
        (292, 468, 694, 494),
        (292, 532, 640, 558),
    ):
        draw.rounded_rectangle(box, radius=13, fill=(194, 207, 221, 255))

    nib_shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    nib_shadow_draw = ImageDraw.Draw(nib_shadow)
    nib_shadow_draw.polygon(((640, 596), (794, 750), (668, 876), (514, 722)), fill=(20, 31, 47, 70))
    nib_shadow = nib_shadow.filter(ImageFilter.GaussianBlur(20))
    image.alpha_composite(nib_shadow)

    nib_points = ((626, 566), (788, 728), (668, 848), (506, 686))
    draw.polygon(nib_points, fill=(236, 193, 106, 255), outline=(167, 125, 54, 255))
    draw.polygon(((626, 566), (706, 646), (582, 770), (506, 686)), fill=(247, 223, 170, 245))
    draw.polygon(((668, 848), (642, 754), (718, 678), (810, 704)), fill=(213, 164, 82, 255))
    draw.line((626, 566, 788, 728), fill=(250, 236, 198, 160), width=10)
    draw.line((648, 646, 648, 796), fill=(133, 85, 41, 255), width=10)
    draw.ellipse((624, 670, 672, 718), fill=(247, 239, 220, 255), outline=(167, 125, 54, 255), width=8)

    return image


def write_iconset(master: Image.Image) -> None:
    ICONSET_DIR.mkdir(parents=True, exist_ok=True)
    sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }
    for filename, target in sizes.items():
        master.resize((target, target), Image.Resampling.LANCZOS).save(ICONSET_DIR / filename)


def main() -> None:
    master = build_master()
    master.save(MASTER_PATH)
    write_iconset(master)
    print(f"Wrote {MASTER_PATH}")
    print(f"Prepared iconset at {ICONSET_DIR}")
    print(f"Run iconutil to produce {ICNS_PATH.name}")


if __name__ == "__main__":
    main()
