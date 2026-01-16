---
title: Use System Font Stack for Performance-Critical Text
impact: MEDIUM-HIGH
impactDescription: 0ms font load time, eliminates FOUT/FOIT
tags: typo, system-fonts, performance, loading, css
---

## Use System Font Stack for Performance-Critical Text

System fonts are already installed on user devices. They render instantly with no download, no FOUT, and no CLS. Use them for UI elements where custom branding is less important than speed.

**Incorrect (custom fonts for everything):**

```css
body {
  font-family: 'Custom Sans', sans-serif;
}

.navigation { font-family: 'Custom Sans', sans-serif; }
.button { font-family: 'Custom Sans', sans-serif; }
.form-label { font-family: 'Custom Sans', sans-serif; }
/* Every element waits for 50KB+ font download */
/* UI feels slow until fonts load */
```

**Correct (system fonts for UI, custom for branding):**

```css
/* System font stack for UI elements */
:root {
  --font-system: -apple-system, BlinkMacSystemFont, 'Segoe UI',
    Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans',
    'Helvetica Neue', sans-serif;

  --font-brand: 'Brand Font', var(--font-system);
}

/* System fonts for instant UI rendering */
body { font-family: var(--font-system); }
.navigation { font-family: var(--font-system); }
.button { font-family: var(--font-system); }
.form-label { font-family: var(--font-system); }

/* Custom font only for brand-critical elements */
h1, h2, .hero-title { font-family: var(--font-brand); }
.logo { font-family: var(--font-brand); }
/* UI renders instantly, headings get branding */
```

**System font stack order:**
1. `-apple-system` (iOS/macOS San Francisco)
2. `BlinkMacSystemFont` (macOS Chrome)
3. `Segoe UI` (Windows)
4. `Roboto` (Android)
5. Generic `sans-serif` fallback

Reference: [CSS Tricks System Font Stack](https://css-tricks.com/snippets/css/system-font-stack/)
