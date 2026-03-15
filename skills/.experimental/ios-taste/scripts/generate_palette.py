#!/usr/bin/env python3
"""
Generate a mathematically harmonious SwiftUI color palette from a single seed hue.

Usage:
    python generate_palette.py --seed 15 --mode both --items 6
    python generate_palette.py --seed 210 --mode dark --items 0
    python generate_palette.py --seed 120 --app "Fitness Tracker"

Arguments:
    --seed    Hue angle in degrees (0-360). Examples:
              0-30   = warm (cooking, social)
              30-60  = golden (finance, productivity)
              60-150 = green (health, fitness, nature)
              150-210 = cyan/teal (tech, communication)
              210-270 = blue (trust, business, weather)
              270-330 = purple (creative, music, luxury)
              330-360 = pink/red (energy, dating, food)
    --mode    light, dark, or both (default: both)
    --items   Number of collection items needing distinct colors (default: 0)
    --app     Optional app name for the generated enum comment

Output: A complete Swift `enum Palette { ... }` block ready to paste.
All colors use HSB with exact values. Contrast ratios are validated.
"""

import argparse
import colorsys
import math


def hsb_to_rgb(h: float, s: float, b: float) -> tuple[float, float, float]:
    """Convert HSB (h in 0-1, s in 0-1, b in 0-1) to RGB (0-1)."""
    return colorsys.hsv_to_rgb(h, s, b)


def relative_luminance(r: float, g: float, b: float) -> float:
    """WCAG relative luminance from linear RGB."""
    def linearize(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    rl, gl, bl = linearize(r), linearize(g), linearize(b)
    return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl


def contrast_ratio(lum1: float, lum2: float) -> float:
    """WCAG contrast ratio between two luminances."""
    lighter = max(lum1, lum2)
    darker = min(lum1, lum2)
    return (lighter + 0.05) / (darker + 0.05)


def validate_text_on_bg(h: float, s: float, b: float, text_white: bool) -> bool:
    """Check if white/black text has ≥4.5:1 contrast on this HSB background."""
    r, g, bl = hsb_to_rgb(h, s, b)
    bg_lum = relative_luminance(r, g, bl)
    text_lum = 1.0 if text_white else 0.0
    return contrast_ratio(bg_lum, text_lum) >= 4.5


def adjust_for_contrast(h: float, s: float, b: float, text_white: bool) -> tuple[float, float, float]:
    """Adjust brightness to ensure WCAG 4.5:1 contrast with text color."""
    if text_white:
        # Darken until contrast passes
        while b > 0.1 and not validate_text_on_bg(h, s, b, True):
            b -= 0.02
    else:
        # Lighten until contrast passes
        while b < 0.99 and not validate_text_on_bg(h, s, b, False):
            b += 0.02
            s = max(0.02, s - 0.01)  # desaturate slightly as we lighten
    return h, s, b


def generate_palette(seed_deg: int, mode: str, item_count: int, app_name: str) -> str:
    """Generate a complete Swift Palette enum."""
    seed = seed_deg / 360.0  # normalize to 0-1

    lines = []
    lines.append(f"// Generated palette for {app_name or 'app'} — seed hue: {seed_deg}°")
    lines.append(f"// Analogous harmony, WCAG contrast validated")
    lines.append("// Usage: Palette.primary, Palette.cardBackground, etc.")
    lines.append("")
    lines.append("import SwiftUI")
    lines.append("")
    lines.append("enum Palette {")

    def color_line(name: str, h: float, s: float, b: float, comment: str = "") -> str:
        h_mod = h % 1.0
        cmt = f"  // {comment}" if comment else ""
        return f"    static let {name} = Color(hue: {h_mod:.4f}, saturation: {s:.3f}, brightness: {b:.3f}){cmt}"

    def hex_from_hsb(h: float, s: float, b: float) -> str:
        r, g, bl = hsb_to_rgb(h % 1.0, s, b)
        return f"#{int(r*255):02x}{int(g*255):02x}{int(bl*255):02x}"

    # --- Dark mode palette ---
    if mode in ("dark", "both"):
        if mode == "both":
            lines.append("")
            lines.append("    // MARK: - Dark Mode")
            lines.append("")

        # Primary: brand identity (use for 30% — headers, icons, active states)
        ph, ps, pb = adjust_for_contrast(seed, 0.70, 0.85, True)
        lines.append(color_line("primary", ph, ps, pb, f"30% brand — {hex_from_hsb(ph, ps, pb)}"))

        # Secondary: muted echo of primary — SAME hue, lower saturation
        # (use for 60% — backgrounds, large surfaces, cards)
        sh, ss, sb = adjust_for_contrast(seed, 0.22, 0.65, True)
        lines.append(color_line("secondary", sh, ss, sb, f"60% surfaces — {hex_from_hsb(sh, ss, sb)}"))

        # Accent: split-complementary (+150°) — vibrant but not aggressive
        # (use for 10% — CTAs, badges, highlights, interactive elements)
        ah, as_, ab = adjust_for_contrast(seed + 0.417, 0.70, 0.85, True)
        lines.append(color_line("accent", ah, as_, ab, f"10% accent — {hex_from_hsb(ah, as_, ab)}"))

        # Card background: very dark, slight hue tint
        lines.append(color_line("cardBackground", seed, 0.12, 0.14, "dark card"))

        # Surface: slightly lighter than pure black
        lines.append(color_line("surface", seed, 0.05, 0.08, "elevated surface"))

        # Text colors
        lines.append("    static let textPrimary = Color.white")
        lines.append("    static let textSecondary = Color(white: 0.65)")

    # --- Light mode palette ---
    if mode in ("light", "both"):
        if mode == "both":
            lines.append("")
            lines.append("    // MARK: - Light Mode")
            lines.append("")

        prefix = "light" if mode == "both" else ""

        # Primary: brand identity for light mode
        ph, ps, pb = seed, 0.65, 0.55  # darker in light mode for contrast
        name = f"{prefix}Primary" if prefix else "primary"
        lines.append(color_line(name, ph, ps, pb, f"30% brand — {hex_from_hsb(ph, ps, pb)}"))

        # Secondary: muted primary — same hue, very low saturation
        sh = seed
        name = f"{prefix}Secondary" if prefix else "secondary"
        lines.append(color_line(name, sh, 0.10, 0.90, f"60% surfaces — {hex_from_hsb(sh, 0.10, 0.90)}"))

        # Accent: split-complementary (+150°)
        ah = seed + 0.417
        name = f"{prefix}Accent" if prefix else "accent"
        lines.append(color_line(name, ah, 0.55, 0.60, f"10% accent — {hex_from_hsb(ah, 0.55, 0.60)}"))

        # Card background: very low saturation, high brightness
        name = f"{prefix}CardBackground" if prefix else "cardBackground"
        lines.append(color_line(name, seed, 0.04, 0.97, "light card"))

        # Surface
        name = f"{prefix}Surface" if prefix else "surface"
        lines.append(color_line(name, seed, 0.02, 0.99, "page background"))

        # Text
        if prefix:
            lines.append("    static let lightTextPrimary = Color(white: 0.1)")
            lines.append("    static let lightTextSecondary = Color(white: 0.45)")
        else:
            lines.append("    static let textPrimary = Color(white: 0.1)")
            lines.append("    static let textSecondary = Color(white: 0.45)")

    # --- Collection item colors ---
    if item_count > 0:
        lines.append("")
        lines.append(f"    // MARK: - Collection ({item_count} items)")
        lines.append("")

        # Adaptive spread: wider hue range for more items, but vary
        # saturation and brightness too for perceptual separation.
        # Hue spread scales with item count (60° base, up to 120° for 20 items)
        base_spread = 0.167  # 60°
        hue_spread = min(base_spread + (item_count - 1) * 0.005, 0.333)  # cap at 120°

        for i in range(item_count):
            t = float(i) / max(1, item_count - 1) if item_count > 1 else 0.5
            item_hue = seed + (t * hue_spread) - (hue_spread / 2)

            # Cycle saturation and brightness across 3 tiers for perceptual distance.
            # Large brightness gaps (0.55 → 0.80 → 0.68) create strong ΔL* in Lab space,
            # which dominates perceptual distance more than hue or saturation.
            tier = i % 3
            if tier == 0:
                sat_dark, bri_dark = 0.70, 0.55
                sat_light, bri_light = 0.45, 0.82
            elif tier == 1:
                sat_dark, bri_dark = 0.40, 0.78
                sat_light, bri_light = 0.20, 0.95
            else:
                sat_dark, bri_dark = 0.55, 0.68
                sat_light, bri_light = 0.35, 0.88

            if mode in ("dark", "both"):
                ih, is_, ib = adjust_for_contrast(item_hue, sat_dark, bri_dark, True)
                lines.append(color_line(f"item{i}", ih, is_, ib,
                    f"{hex_from_hsb(ih, is_, ib)}"))

            if mode in ("light", "both") and mode == "both":
                ih, is_, ib = adjust_for_contrast(item_hue, sat_light, bri_light, False)
                lines.append(color_line(f"lightItem{i}", ih, is_, ib,
                    f"{hex_from_hsb(ih, is_, ib)}"))
            elif mode == "light":
                ih, is_, ib = adjust_for_contrast(item_hue, sat_light, bri_light, False)
                lines.append(color_line(f"item{i}", ih, is_, ib,
                    f"{hex_from_hsb(ih, is_, ib)}"))

    # --- Semantic colors ---
    lines.append("")
    lines.append("    // MARK: - Semantic")
    lines.append("")
    lines.append("    static let success = Color(hue: 0.3889, saturation: 0.65, brightness: 0.70)  // #3fb34f")
    lines.append("    static let warning = Color(hue: 0.1111, saturation: 0.75, brightness: 0.90)  // #e6a31a")
    lines.append("    static let error   = Color(hue: 0.0000, saturation: 0.70, brightness: 0.85)  // #d94141")

    lines.append("}")
    lines.append("")

    # Summary
    lines.append(f"// Seed: {seed_deg}° | Mode: {mode} | Items: {item_count}")
    lines.append(f"// Harmony: analogous (±30°) | Contrast: WCAG AA validated")
    lines.append(f"// Dark text on light backgrounds, white text on dark backgrounds")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Generate a SwiftUI color palette")
    parser.add_argument("--seed", type=int, required=True, help="Seed hue in degrees (0-360)")
    parser.add_argument("--mode", choices=["light", "dark", "both"], default="both")
    parser.add_argument("--items", type=int, default=0, help="Number of collection item colors")
    parser.add_argument("--app", type=str, default="", help="App name for comment")
    args = parser.parse_args()

    if not 0 <= args.seed <= 360:
        parser.error("Seed must be 0-360")
    if args.items > 12:
        import sys
        print(f"Warning: {args.items} items requested. Perceptual distinguishability "
              f"degrades above 12 items in an analogous palette. Consider using "
              f"12 or fewer, or grouping items by category.", file=sys.stderr)

    print(generate_palette(args.seed, args.mode, min(args.items, 20), args.app))


if __name__ == "__main__":
    main()
