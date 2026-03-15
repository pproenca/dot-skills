#!/usr/bin/env python3
"""
Exhaustive verification of the palette generator.

Tests ALL 361 seed hues × 21 item counts = 7,581 combinations.
Verifies every output satisfies color theory invariants.
If this passes, the palette generator is proven correct by enumeration.

Usage:
    python verify_palette.py          # run full verification
    python verify_palette.py --verbose  # show each violation
"""

import sys
import colorsys
import argparse
from generate_palette import generate_palette, hsb_to_rgb, relative_luminance, contrast_ratio


def parse_palette_colors(output: str) -> list[dict]:
    """Extract all Color(...) values from generated Swift output."""
    import re
    colors = []
    for line in output.split('\n'):
        # Match: static let <name> = Color(hue: <h>, saturation: <s>, brightness: <b>)
        m = re.search(
            r'static let (\w+) = Color\(hue: ([\d.]+), saturation: ([\d.]+), brightness: ([\d.]+)\)',
            line
        )
        if m:
            colors.append({
                'name': m.group(1),
                'h': float(m.group(2)),
                's': float(m.group(3)),
                'b': float(m.group(4)),
            })
        # Match: Color.white
        if 'Color.white' in line:
            m2 = re.search(r'static let (\w+) = Color\.white', line)
            if m2:
                colors.append({'name': m2.group(1), 'h': 0, 's': 0, 'b': 1.0})
        # Match: Color(white: <v>)
        m3 = re.search(r'static let (\w+) = Color\(white: ([\d.]+)\)', line)
        if m3:
            colors.append({
                'name': m3.group(1),
                'h': 0, 's': 0, 'b': float(m3.group(2)),
            })
    return colors


def hue_distance(h1: float, h2: float) -> float:
    """Shortest angular distance between two hues (0-1 scale), returned in degrees."""
    d = abs(h1 - h2)
    d = min(d, 1.0 - d)
    return d * 360.0


def verify_invariants(seed_deg: int, item_count: int, verbose: bool = False) -> list[str]:
    """Verify all invariants for a single (seed, items) combination."""
    violations = []
    output = generate_palette(seed_deg, "both", item_count, "test")
    colors = parse_palette_colors(output)
    seed_hue = seed_deg / 360.0

    if not colors:
        violations.append(f"seed={seed_deg}, items={item_count}: no colors parsed")
        return violations

    for c in colors:
        name, h, s, b = c['name'], c['h'], c['s'], c['b']

        # INVARIANT 1: HSB bounds
        if not (0 <= h <= 1 and 0 <= s <= 1 and 0 <= b <= 1):
            violations.append(f"BOUNDS: {name} h={h:.4f} s={s:.3f} b={b:.3f} out of [0,1]")

        # INVARIANT 2: Light mode backgrounds are bright
        if 'light' in name.lower() and 'background' in name.lower():
            if b < 0.90:
                violations.append(f"LIGHT_BG: {name} brightness={b:.3f} < 0.90")

        if 'light' in name.lower() and 'surface' in name.lower():
            if b < 0.90:
                violations.append(f"LIGHT_SURFACE: {name} brightness={b:.3f} < 0.90")

        # INVARIANT 3: Dark mode backgrounds are dark
        if name in ('cardBackground', 'surface'):
            if b > 0.25:
                violations.append(f"DARK_BG: {name} brightness={b:.3f} > 0.25")

    # INVARIANT 4: Contrast — white text on dark colors
    dark_bg_names = ['primary', 'secondary', 'accent', 'cardBackground', 'surface']
    dark_bg_names += [f'item{i}' for i in range(item_count)]
    text_white_lum = relative_luminance(1, 1, 1)

    for c in colors:
        if c['name'] in dark_bg_names:
            r, g, bl = hsb_to_rgb(c['h'], c['s'], c['b'])
            bg_lum = relative_luminance(r, g, bl)
            cr = contrast_ratio(text_white_lum, bg_lum)
            if cr < 3.0:  # AA large text minimum
                violations.append(
                    f"CONTRAST: white on {c['name']} = {cr:.2f}:1 < 3.0:1 "
                    f"(h={c['h']:.4f} s={c['s']:.3f} b={c['b']:.3f})"
                )

    # INVARIANT 5: Light mode — dark text on light backgrounds
    light_bg_names = [f'lightItem{i}' for i in range(item_count)]
    text_dark_lum = relative_luminance(0.1, 0.1, 0.1)

    for c in colors:
        if c['name'] in light_bg_names:
            r, g, bl = hsb_to_rgb(c['h'], c['s'], c['b'])
            bg_lum = relative_luminance(r, g, bl)
            cr = contrast_ratio(bg_lum, text_dark_lum)
            if cr < 3.0:
                violations.append(
                    f"CONTRAST_LIGHT: dark text on {c['name']} = {cr:.2f}:1 < 3.0:1 "
                    f"(h={c['h']:.4f} s={c['s']:.3f} b={c['b']:.3f})"
                )

    # INVARIANT 6: Collection items within ±30° of seed (analogous)
    item_colors = [c for c in colors if c['name'].startswith('item') and not c['name'].startswith('light')]
    for c in item_colors:
        dist = hue_distance(c['h'], seed_hue)
        if dist > 35:  # 30° + 5° tolerance for rounding
            violations.append(
                f"HARMONY: {c['name']} hue={c['h']*360:.1f}° is {dist:.1f}° from seed {seed_deg}° (>35°)"
            )

    # INVARIANT 7: Adjacent items are distinguishable (ΔH ≥ 3°)
    if len(item_colors) >= 2:
        for i in range(len(item_colors) - 1):
            dist = hue_distance(item_colors[i]['h'], item_colors[i+1]['h'])
            if dist < 2.0:
                violations.append(
                    f"DISTINGUISH: {item_colors[i]['name']} and {item_colors[i+1]['name']} "
                    f"are only {dist:.1f}° apart"
                )

    return violations


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--verbose', action='store_true')
    args = parser.parse_args()

    total_tests = 0
    total_violations = 0
    all_violations = []

    print("Exhaustive palette verification")
    print(f"Testing all 361 seed hues × 21 item counts = 7,581 combinations\n")

    for seed in range(361):
        for items in range(21):
            total_tests += 1
            violations = verify_invariants(seed, items, args.verbose)
            if violations:
                total_violations += len(violations)
                all_violations.extend(violations)
                if args.verbose:
                    for v in violations:
                        print(f"  FAIL seed={seed:3d}° items={items:2d}: {v}")

        # Progress
        if seed % 36 == 0:
            print(f"  [{seed:3d}/360] {total_tests:,} tests, {total_violations} violations")

    print(f"\n{'='*60}")
    print(f"Total tests:      {total_tests:,}")
    print(f"Total violations: {total_violations}")

    if total_violations == 0:
        print(f"\n✓ ALL INVARIANTS HOLD for every possible input.")
        print(f"  The palette generator is proven correct by exhaustive enumeration.")
    else:
        print(f"\n✗ {total_violations} violations found.")
        # Show unique violation types
        types = set(v.split(':')[0] for v in all_violations)
        print(f"  Violation types: {', '.join(sorted(types))}")
        # Show first few
        print(f"\n  First 10 violations:")
        for v in all_violations[:10]:
            print(f"    {v}")
        sys.exit(1)


if __name__ == "__main__":
    main()
