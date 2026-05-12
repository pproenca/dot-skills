#!/usr/bin/env python3
"""
Exhaustive verification of the palette generator.

Tests all 361 seed hues x 21 item counts = 7,581 combinations.
Verifies every output satisfies color theory invariants.
If this passes, the palette generator is proven correct by enumeration.

Usage:
    python verify_palette.py             # run full verification
    python verify_palette.py --verbose   # show each violation
    python verify_palette.py --pair "#737373" "#ffffff"  # ad-hoc contrast check
"""

import sys
import argparse
import math
import re
import colorsys
from generate_palette import generate_palette, relative_luminance, contrast_ratio


# ---------- CIE Lab conversion for perceptual distance ----------

def rgb_to_xyz(r: float, g: float, b: float) -> tuple[float, float, float]:
    def linearize(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    rl, gl, bl = linearize(r), linearize(g), linearize(b)
    x = 0.4124564 * rl + 0.3575761 * gl + 0.1804375 * bl
    y = 0.2126729 * rl + 0.7151522 * gl + 0.0721750 * bl
    z = 0.0193339 * rl + 0.1191920 * gl + 0.9503041 * bl
    return x, y, z


def xyz_to_lab(x: float, y: float, z: float) -> tuple[float, float, float]:
    xn, yn, zn = 0.95047, 1.00000, 1.08883
    def f(t):
        return t ** (1 / 3) if t > 0.008856 else (7.787 * t) + (16 / 116)
    fx, fy, fz = f(x / xn), f(y / yn), f(z / zn)
    L = 116 * fy - 16
    a = 500 * (fx - fy)
    b = 200 * (fy - fz)
    return L, a, b


def hex_to_rgb(h: str) -> tuple[float, float, float]:
    h = h.lstrip("#")
    return int(h[0:2], 16) / 255.0, int(h[2:4], 16) / 255.0, int(h[4:6], 16) / 255.0


def hex_to_lab(h: str) -> tuple[float, float, float]:
    r, g, b = hex_to_rgb(h)
    x, y, z = rgb_to_xyz(r, g, b)
    return xyz_to_lab(x, y, z)


def hex_to_hue(h: str) -> float:
    """Return HSB hue in 0-1."""
    r, g, b = hex_to_rgb(h)
    hue, _s, _v = colorsys.rgb_to_hsv(r, g, b)
    return hue


def delta_e(lab1: tuple, lab2: tuple) -> float:
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(lab1, lab2)))


def hue_distance(h1: float, h2: float) -> float:
    d = abs(h1 - h2)
    d = min(d, 1.0 - d)
    return d * 360.0


# ---------- Parser for CSS output ----------

TOKEN_RE = re.compile(r"^\s*--color-([\w-]+):\s*(#[0-9a-fA-F]{6});", re.MULTILINE)


def parse_palette(output: str) -> dict[str, dict[str, str]]:
    """Return {'light': {token: hex}, 'dark': {token: hex}}."""
    blocks = {"light": {}, "dark": {}}
    current = None
    for line in output.split("\n"):
        if ":root" in line or ".light {" in line:
            current = "light"
            continue
        if ".dark {" in line:
            current = "dark"
            continue
        if line.strip() == "}":
            current = None
            continue
        if current is None:
            continue
        m = TOKEN_RE.match(line)
        if m:
            blocks[current][m.group(1)] = m.group(2).lower()
    return blocks


# ---------- Invariants ----------

def verify_invariants(seed_deg: int, item_count: int, verbose: bool = False) -> list[str]:
    violations = []
    output = generate_palette(seed_deg, "both", item_count, "test")
    blocks = parse_palette(output)
    seed_hue = seed_deg / 360.0

    if not blocks["light"] or not blocks["dark"]:
        violations.append(f"seed={seed_deg}, items={item_count}: no colors parsed")
        return violations

    # 1. Dark theme — white text contrast on key surfaces
    text_white = relative_luminance(1, 1, 1)
    for token in ("background", "card", "primary", "secondary", "accent"):
        hexv = blocks["dark"].get(token)
        if not hexv:
            continue
        r, g, b = hex_to_rgb(hexv)
        bg_lum = relative_luminance(r, g, b)
        cr = contrast_ratio(text_white, bg_lum)
        if cr < 3.0:
            violations.append(
                f"DARK_CONTRAST: white-on-{token} = {cr:.2f}:1 < 3.0:1 (seed={seed_deg}, items={item_count})"
            )

    # 2. Light theme — dark text contrast on key surfaces
    text_dark = relative_luminance(0.1, 0.1, 0.1)
    for token in ("background", "card", "secondary", "muted"):
        hexv = blocks["light"].get(token)
        if not hexv:
            continue
        r, g, b = hex_to_rgb(hexv)
        bg_lum = relative_luminance(r, g, b)
        cr = contrast_ratio(bg_lum, text_dark)
        if cr < 3.0:
            violations.append(
                f"LIGHT_CONTRAST: dark-text-on-{token} = {cr:.2f}:1 < 3.0:1 (seed={seed_deg}, items={item_count})"
            )

    # 3. Light background is bright; dark background is dark
    light_bg = hex_to_rgb(blocks["light"].get("background", "#ffffff"))
    if relative_luminance(*light_bg) < 0.80:
        violations.append(f"LIGHT_BG_DIM: seed={seed_deg} (luminance {relative_luminance(*light_bg):.2f} < 0.80)")
    dark_bg = hex_to_rgb(blocks["dark"].get("background", "#000000"))
    if relative_luminance(*dark_bg) > 0.10:
        violations.append(f"DARK_BG_BRIGHT: seed={seed_deg} (luminance {relative_luminance(*dark_bg):.2f} > 0.10)")

    # 4. Collection items within harmonic range of seed
    max_dist = 35.0 if item_count <= 6 else 65.0
    chart_keys = [f"chart-{i + 1}" for i in range(item_count)]
    for theme in ("dark", "light"):
        for k in chart_keys:
            hexv = blocks[theme].get(k)
            if not hexv:
                continue
            h = hex_to_hue(hexv)
            dist = hue_distance(h, seed_hue)
            if dist > max_dist:
                violations.append(
                    f"HARMONY: {theme}.{k}={hexv} is {dist:.1f}deg from seed {seed_deg}deg (>{max_dist:.0f}deg)"
                )

    # 5. Pairwise perceptual distance (ΔE) for collection
    for theme in ("dark", "light"):
        hexes = [blocks[theme].get(k) for k in chart_keys if blocks[theme].get(k)]
        for i in range(len(hexes)):
            for j in range(i + 1, len(hexes)):
                de = delta_e(hex_to_lab(hexes[i]), hex_to_lab(hexes[j]))
                if de < 4.0:
                    violations.append(
                        f"PERCEPTUAL: {theme} chart-{i+1} and chart-{j+1} ΔE*={de:.1f} < 4.0 (seed={seed_deg})"
                    )

    # 6. Core palette colors (primary/secondary/accent) perceptually distinct
    for theme in ("dark", "light"):
        keys = ("primary", "secondary", "accent")
        core = [(k, blocks[theme].get(k)) for k in keys if blocks[theme].get(k)]
        for i in range(len(core)):
            for j in range(i + 1, len(core)):
                de = delta_e(hex_to_lab(core[i][1]), hex_to_lab(core[j][1]))
                if de < 15.0:
                    violations.append(
                        f"CORE_SEPARATION: {theme}.{core[i][0]} vs {core[j][0]} ΔE*={de:.1f} < 15.0 (seed={seed_deg})"
                    )

    # 7. Background and card layers visually distinct
    for theme in ("dark", "light"):
        bg = blocks[theme].get("background")
        card = blocks[theme].get("card")
        if bg and card:
            de = delta_e(hex_to_lab(bg), hex_to_lab(card))
            if de < 2.0:
                violations.append(
                    f"BG_LAYERS: {theme} background vs card ΔE*={de:.1f} < 2.0 (seed={seed_deg})"
                )

    return violations


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument(
        "--pair",
        nargs=2,
        metavar=("FG", "BG"),
        help="Ad-hoc contrast check between two hex colors",
    )
    args = parser.parse_args()

    if args.pair:
        fg, bg = args.pair
        fg_r, fg_g, fg_b = hex_to_rgb(fg)
        bg_r, bg_g, bg_b = hex_to_rgb(bg)
        cr = contrast_ratio(relative_luminance(fg_r, fg_g, fg_b), relative_luminance(bg_r, bg_g, bg_b))
        status_body = "PASS body (>=4.5:1)" if cr >= 4.5 else "FAIL body"
        status_large = "PASS large/UI (>=3:1)" if cr >= 3.0 else "FAIL large/UI"
        print(f"{fg} on {bg} -> contrast {cr:.2f}:1  |  {status_body}, {status_large}")
        return

    total_tests = 0
    total_violations = 0
    all_violations: list[str] = []

    print("Exhaustive palette verification")
    print("Testing 361 seed hues x 21 item counts = 7,581 combinations\n")

    for seed in range(361):
        for items in range(21):
            total_tests += 1
            violations = verify_invariants(seed, items, args.verbose)
            if violations:
                total_violations += len(violations)
                all_violations.extend(violations)
                if args.verbose:
                    for v in violations:
                        print(f"  FAIL seed={seed:3d} items={items:2d}: {v}")

        if seed % 36 == 0:
            print(f"  [{seed:3d}/360] {total_tests:,} tests, {total_violations} violations")

    print(f"\n{'=' * 60}")
    print(f"Total tests:      {total_tests:,}")
    print(f"Total violations: {total_violations}")

    if total_violations == 0:
        print("\n  ALL INVARIANTS HOLD for every possible input.")
        print("  The palette generator is proven correct by exhaustive enumeration.")
    else:
        types = set(v.split(":")[0] for v in all_violations)
        print(f"\n  Violation types: {', '.join(sorted(types))}")
        print("\n  First 10 violations:")
        for v in all_violations[:10]:
            print(f"    {v}")
        sys.exit(1)


if __name__ == "__main__":
    main()
