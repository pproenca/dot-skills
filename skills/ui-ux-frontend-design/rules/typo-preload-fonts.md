---
title: Preload Critical Web Fonts
impact: MEDIUM-HIGH
impactDescription: reduces font load time by 100-300ms
tags: typo, preload, fonts, performance, loading
---

## Preload Critical Web Fonts

Fonts are discovered late in the loading waterfall (after CSS parses). Preloading tells the browser to fetch fonts immediately, reducing time to first render.

**Incorrect (fonts discovered late in waterfall):**

```html
<head>
  <link rel="stylesheet" href="styles.css">
  <!-- styles.css contains @font-face rules -->
  <!-- Browser: download CSS → parse → discover font → download font -->
  <!-- Font download starts 200-500ms after CSS -->
</head>
```

**Correct (fonts preloaded immediately):**

```html
<head>
  <!-- Preload critical fonts in <head> -->
  <link
    rel="preload"
    href="/fonts/brand-regular.woff2"
    as="font"
    type="font/woff2"
    crossorigin
  >
  <link
    rel="preload"
    href="/fonts/brand-bold.woff2"
    as="font"
    type="font/woff2"
    crossorigin
  >
  <!-- Font download starts immediately, parallel with CSS -->

  <link rel="stylesheet" href="styles.css">
</head>
```

**Preloading guidelines:**
- Only preload fonts used above-the-fold (1-2 fonts max)
- Always include `crossorigin` (even for same-origin fonts)
- Use WOFF2 format (smallest, best compression)
- Match preload href exactly with @font-face src

**Subsetting for smaller files:**

```bash
# Use glyphanger to subset fonts
glyphanger --whitelist="ABCDEFGHIJKLMNOPQRSTUVWXYZ..." --subset="*.woff2"
# Reduces font file from 50KB to 15KB
```

Reference: [web.dev Preload Fonts](https://web.dev/articles/preload-critical-assets)
