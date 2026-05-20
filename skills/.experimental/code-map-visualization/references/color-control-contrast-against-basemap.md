---
title: Control Cell Contrast Against the Basemap
impact: HIGH
impactDescription: prevents cells washing out against the background
tags: color, contrast, luminance, basemap, legibility
---

## Control Cell Contrast Against the Basemap

A colour only reads against its background. Light cells on a white basemap, or a dark theme that drops the same palette onto near-black, collapse the luminance contrast that lets the eye separate cell from ground and cell from cell. Set the basemap to a neutral mid-tone (or pick per-theme palettes), and check foreground/background contrast in a perceptual space rather than trusting raw RGB. The same data should stay legible whether the user is in light or dark mode.

**Incorrect (one palette, any background):**

```typescript
canvas.style.background = theme.bg;          // could be #fff or #111
getFillColor: (c) => domainColor(c.domain);  // light hues vanish on white, dark on black
```

**Correct (theme-aware palette plus a verified contrast floor):**

```typescript
canvas.style.background = theme.bg;
const palette = theme.dark ? darkSafePalette : lightSafePalette;
getFillColor: (c) => ensureContrast(palette(c.domain), theme.bg, 3.0); // nudge L* to keep >=3:1
```

**When NOT to apply:**
- A deliberately de-emphasised layer (greyed-out unchanged files behind a diff) *should* have low contrast — that low contrast is itself the encoding.

Reference: [WCAG 2.2 — Non-text Contrast (1.4.11)](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html); [W3C CSS Color 4 — OKLCH](https://www.w3.org/TR/css-color-4/#ok-lab)
