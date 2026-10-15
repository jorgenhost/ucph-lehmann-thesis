"""Extract individual UCPH logo variants from the official logo sheets.

The University of Copenhagen distributes its logos as A3 Illustrator sheets
(PDF) holding several variants each. This script cuts each variant out as a
standalone, tight SVG in `assets/logos/`.

How it works, per variant:
  1. Crop the sheet's page to a box around the variant (pypdf).
  2. Convert that page to SVG (pdftocairo, from poppler-utils). All lettering
     in the sheets is already outlined, so no fonts are involved.
  3. Keep only the shapes that lie *entirely* inside the crop box. Anything
     merely overlapping the box (a neighbouring dot, a background panel, a
     guide frame) is dropped, so the crop box can be generous.
  4. Write a minimal SVG with transforms baked in and a tight viewBox.

Usage (from the repo root):
    python3 tools/extract-logos.py            # all variants
    python3 tools/extract-logos.py seal       # one variant

Requirements: pdftocairo (poppler-utils), `pip install pypdf svgelements`.

Source sheets are expected in tools/sources/ (not committed; download them
from https://designguide.ku.dk/):
    KU_RGB.pdf             - colour logos, RGB
    KU_outline-logo.pdf    - negative (white) logos on dark backgrounds
    KU-logo_streg-logo.pdf - line-art (black) seal
"""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path

import svgelements as se
from pypdf import PdfReader, PdfWriter

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ROOT / "tools" / "sources"
OUT = ROOT / "assets" / "logos"

# Crop boxes are (x0, y0, x1, y1) in PDF points, measured from the TOP-LEFT
# corner of the sheet (as seen in a viewer). They only need to enclose the
# variant fully; tightening happens automatically.
VARIANTS: dict[str, tuple[str, tuple[float, float, float, float]]] = {
    # --- colour (RGB sheet, landscape A3) ---------------------------------
    "seal":               ("KU_RGB.pdf", (671, 158, 734, 221)),
    "logo-en":            ("KU_RGB.pdf", (648, 158, 1124, 260)),
    "logo-da":            ("KU_RGB.pdf", (60, 158, 505, 260)),
    "logo-right-en":      ("KU_RGB.pdf", (881, 430, 1153, 530)),
    "logo-right-da":      ("KU_RGB.pdf", (309, 430, 565, 530)),
    "logo-stacked-en":    ("KU_RGB.pdf", (620, 575, 835, 740)),
    "logo-stacked-da":    ("KU_RGB.pdf", (32, 575, 232, 740)),
    "wordmark-en":        ("KU_RGB.pdf", (739, 202, 1117, 232)),
    "wordmark-da":        ("KU_RGB.pdf", (150, 202, 499, 232)),
    # --- negative / white (outline sheet, landscape A3) --------------------
    "seal-negative":            ("KU_outline-logo.pdf", (293, 158, 373, 237)),
    "logo-stacked-negative-en": ("KU_outline-logo.pdf", (754, 156, 1021, 322)),
    "logo-stacked-negative-da": ("KU_outline-logo.pdf", (268, 156, 514, 322)),
    # --- line art / black (streg sheet, portrait A3) -----------------------
    "seal-line":               ("KU-logo_streg-logo.pdf", (258, 26, 585, 353)),
}

TOL = 0.5  # pt of slack when testing containment


def crop_to_svg(sheet: Path, box: tuple[float, float, float, float], tmp: Path) -> Path:
    reader = PdfReader(sheet)
    page = reader.pages[0]
    page_h = float(page.mediabox.height)
    x0, y0, x1, y1 = box
    rect = (x0, page_h - y1, x1, page_h - y0)
    page.mediabox.lower_left = rect[:2]
    page.mediabox.upper_right = rect[2:]
    page.cropbox = page.mediabox
    for key in ("/TrimBox", "/BleedBox", "/ArtBox"):
        if key in page:
            del page[key]
    writer = PdfWriter()
    writer.add_page(page)
    pdf = tmp / "crop.pdf"
    with pdf.open("wb") as fh:
        writer.write(fh)
    svg = tmp / "crop.svg"
    subprocess.run(["pdftocairo", "-svg", str(pdf), str(svg)], check=True)
    return svg


def colour(c) -> str | None:
    if c is None or c.value is None:
        return None
    if c.alpha == 0:
        return None
    return c.hexrgb


def extract(name: str) -> Path:
    sheet_name, box = VARIANTS[name]
    with tempfile.TemporaryDirectory() as td:
        svg_path = crop_to_svg(SOURCES / sheet_name, box, Path(td))
        doc = se.SVG.parse(str(svg_path), reify=True)
        vw, vh = doc.width, doc.height

        kept = []
        for el in doc.elements():
            if not isinstance(el, se.Shape) or isinstance(el, se.SVG):
                continue
            path = se.Path(el)
            path.reify()
            if len(path) == 0:
                continue
            bb = path.bbox(with_stroke=True)
            if bb is None:
                continue
            bx0, by0, bx1, by1 = bb
            inside = bx0 >= -TOL and by0 >= -TOL and bx1 <= vw + TOL and by1 <= vh + TOL
            # drop white rectangles that only paint the sheet background
            fill = colour(el.fill)
            stroke = colour(el.stroke)
            if not inside or (fill is None and stroke is None):
                continue
            kept.append((path, fill, stroke, el))

    if not kept:
        raise SystemExit(f"{name}: nothing extracted - check crop box")

    xs0, ys0, xs1, ys1 = zip(*(p.bbox(with_stroke=True) for p, *_ in kept))
    bx0, by0, bx1, by1 = min(xs0), min(ys0), max(xs1), max(ys1)
    w, h = bx1 - bx0, by1 - by0

    parts = []
    for path, fill, stroke, el in kept:
        path = path * se.Matrix(f"translate({-bx0},{-by0})")
        d = re.sub(r"-?\d+\.\d+", lambda m: f"{float(m.group()):.3f}".rstrip("0").rstrip("."), path.d())
        attrs = [f'd="{d}"']
        attrs.append(f'fill="{fill}"' if fill else 'fill="none"')
        rule = el.values.get("fill-rule")
        if rule and rule != "nonzero":
            attrs.append(f'fill-rule="{rule}"')
        if stroke:
            sw = el.implicit_stroke_width if el.stroke_width else 1
            attrs.append(f'stroke="{stroke}" stroke-width="{sw:.4g}"')
        parts.append(f"<path {' '.join(attrs)}/>")

    svg = (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w:.3f} {h:.3f}" '
        f'width="{w:.3f}pt" height="{h:.3f}pt">\n'
        f"<!-- {name}: extracted from {sheet_name} (University of Copenhagen). "
        f"The logo is the property of the University of Copenhagen. -->\n"
        + "\n".join(parts)
        + "\n</svg>\n"
    )
    out = OUT / f"{name}.svg"
    out.write_text(svg)
    print(f"{name:28s} {len(kept):4d} shapes  {w:7.2f} x {h:6.2f} pt  -> {out.relative_to(ROOT)}")
    return out


def main(argv: list[str]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    names = argv or list(VARIANTS)
    for n in names:
        extract(n)


if __name__ == "__main__":
    main(sys.argv[1:])
