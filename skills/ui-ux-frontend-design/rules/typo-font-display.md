---
title: Use font-display to Control Loading Behavior
impact: MEDIUM-HIGH
impactDescription: eliminates FOIT, reduces CLS from font loading
tags: typo, font-display, performance, fout, foit
---

## Use font-display to Control Loading Behavior

Without `font-display`, browsers may hide text until custom fonts load (FOIT). This creates invisible content and frustrates users. Control this behavior explicitly.

**Incorrect (default browser FOIT behavior):**

```css
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  /* No font-display specified */
  /* Safari hides text indefinitely until font loads */
  /* Chrome/Firefox hide for 3s, then show fallback */
}
/* Users see blank space where text should be */
```

**Correct (explicit font-display strategy):**

```css
/* Option 1: swap - always show text, swap when ready */
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  font-display: swap;
}
/* Text visible immediately with fallback */
/* Swaps to custom font when loaded (may cause reflow) */

/* Option 2: optional - no swap if not cached */
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  font-display: optional;
}
/* Text visible immediately */
/* Custom font only used if already cached (no CLS) */

/* Option 3: fallback - short block, then fallback */
@font-face {
  font-family: 'Brand Font';
  src: url('brand-font.woff2') format('woff2');
  font-display: fallback;
}
/* 100ms block period, then fallback */
/* Swap window of ~3s before giving up */
```

**font-display values:**
- `swap`: Show fallback immediately, always swap (may cause CLS)
- `optional`: No CLS, but font may not appear on first visit
- `fallback`: Brief block, then swap window (balanced)

Reference: [web.dev font-display](https://web.dev/articles/font-display)
