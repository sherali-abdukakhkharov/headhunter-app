from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    parser.add_argument("inputs", nargs="+", type=Path)
    parser.add_argument("--columns", type=int, default=4)
    args = parser.parse_args()

    font = ImageFont.load_default()
    thumb_w, thumb_h = 270, 600
    label_h = 42
    gap = 18
    rows = (len(args.inputs) + args.columns - 1) // args.columns
    canvas = Image.new(
        "RGB",
        (
            gap + args.columns * (thumb_w + gap),
            gap + rows * (thumb_h + label_h + gap),
        ),
        "white",
    )
    draw = ImageDraw.Draw(canvas)

    for index, path in enumerate(args.inputs):
        image = Image.open(path).convert("RGB")
        image.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        col = index % args.columns
        row = index // args.columns
        x = gap + col * (thumb_w + gap)
        y = gap + row * (thumb_h + label_h + gap)
        ix = x + (thumb_w - image.width) // 2
        iy = y + (thumb_h - image.height) // 2
        canvas.paste(image, (ix, iy))
        draw.rectangle((x, y, x + thumb_w, y + thumb_h), outline="#c9d2dc", width=2)
        label = path.stem[:38]
        draw.text((x, y + thumb_h + 8), label, fill="#0b2545", font=font)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(args.output, quality=92)


if __name__ == "__main__":
    main()
