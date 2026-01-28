---
title: Provide All Required Icon Sizes
impact: LOW-MEDIUM
impactDescription: ensures crisp display across all contexts
tags: brand, icons, sizes, resolution, manifest
---

## Provide All Required Icon Sizes

Supply icons in all required sizes (16, 32, 48, 128px) to ensure crisp display everywhere. Missing sizes cause Chrome to scale existing icons, resulting in blurry appearance.

**Incorrect (only one icon size):**

```json
{
  "icons": {
    "128": "icon.png"
  },
  "action": {
    "default_icon": "icon.png"
  }
}
// Chrome scales 128px icon to 16px for toolbar → blurry mess
```

**Correct (all sizes provided):**

```json
{
  "icons": {
    "16": "icons/icon-16.png",
    "32": "icons/icon-32.png",
    "48": "icons/icon-48.png",
    "128": "icons/icon-128.png"
  },
  "action": {
    "default_icon": {
      "16": "icons/icon-16.png",
      "24": "icons/icon-24.png",
      "32": "icons/icon-32.png"
    }
  }
}
```

**Icon size usage:**

| Size | Where Used |
|------|------------|
| 16×16 | Toolbar, favicon, context menu |
| 24×24 | Toolbar on Windows (125% DPI) |
| 32×32 | Toolbar on Retina/HiDPI displays |
| 48×48 | Extensions management page |
| 128×128 | Chrome Web Store, install dialog |

**Creating optimized icons for each size:**

```bash
# Don't just resize - optimize each size
# Small icons need simplified detail

# Generate from SVG with optimized rendering
convert icon.svg -resize 16x16 -density 96 icons/icon-16.png
convert icon.svg -resize 32x32 -density 96 icons/icon-32.png
convert icon.svg -resize 48x48 -density 96 icons/icon-48.png
convert icon.svg -resize 128x128 -density 96 icons/icon-128.png
```

**Icon design per size:**

| Size | Design Approach |
|------|-----------------|
| 16px | Simplify to essential shape, thicken lines, remove fine detail |
| 32px | Moderate detail, clear silhouette |
| 48px | Good detail visible, balanced complexity |
| 128px | Full detail, gradients, shadows acceptable |

**PNG requirements:**
- Format: PNG-24 with alpha transparency
- Background: Transparent (no solid background)
- Shape: Square canvas, icon can be any shape within
- Color profile: sRGB

Reference: [Configure Extension Icons](https://developer.chrome.com/docs/extensions/develop/ui/configure-icons)
