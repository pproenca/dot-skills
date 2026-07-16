---
title: Give custom colors and full-color images dark-appearance variants
tags: color, dark-mode, asset-catalog, images
---

## Give custom colors and full-color images dark-appearance variants

The wrong default is defining a custom brand color or dropping in an illustration with only a universal ("Any") appearance. The color that looked considered on a light surface turns muddy or vibrating on dark ones, and a full-color image with a baked-in white plate glows like a lightbox in a Dark Mode context. Apple's direction is explicit: supply light and dark variants for every custom color — even single-appearance apps need both to support Liquid Glass adaptivity — and modify or duplicate any image asset that only reads in one appearance.

**Evidence of violation:** (a) a `.colorset` whose `Contents.json` defines no `"luminosity" : "dark"` appearance while the color is used on adaptive surfaces — cite the asset path; (b) a full-color `.imageset` (illustration, photo plate, logo lockup) with only a universal appearance, placed on a system background, where a provided dark-mode screenshot shows a glowing plate or vanished detail — the dark screenshot is the required evidence for this leg; without screenshots the image leg is N/A with that reason stated, never PASS. PASS: colorsets with both appearances (cite the `Contents.json` entries); imagesets with a dark variant, template/symbol rendering with dynamic tint, or a both-modes screenshot demonstrating the single asset survives. N/A: deliberately appearance-invariant artwork — a citable single-appearance design note or `Image(decorative:)` fixed-artwork context; absent that evidence, fail closed on the colorset leg. N/A: inline color literals (`Color(red:)`, hex initializers) are the sibling architecture gate's territory (`access-semantic-fonts-and-colors`); this rule judges asset-catalog appearance completeness only.

**Incorrect (one appearance — the cream reads as dirty beige on dark surfaces):**

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : { "red" : "0.980", "green" : "0.953", "blue" : "0.902", "alpha" : "1.000" }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

**Correct (PaperCream declares what it becomes in the dark):**

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : { "red" : "0.980", "green" : "0.953", "blue" : "0.902", "alpha" : "1.000" }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ],
      "color" : {
        "color-space" : "srgb",
        "components" : { "red" : "0.176", "green" : "0.161", "blue" : "0.137", "alpha" : "1.000" }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

Reference: [Human Interface Guidelines — Color](https://developer.apple.com/design/human-interface-guidelines/color), [Human Interface Guidelines — Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
