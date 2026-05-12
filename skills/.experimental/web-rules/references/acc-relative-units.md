---
title: Use `rem` for Text and Spacing; Never Fix Text Size in `px`
impact: CRITICAL
impactDescription: ~7% of users override the default browser font size — px-sized text ignores their preference and is unreadable; rem-based design adapts automatically
tags: acc, relative-units, rem, em, px, root-font-size
---

## Use `rem` for Text and Spacing; Never Fix Text Size in `px`

`rem` is "root em" — sized relative to `<html>`'s `font-size`, which defaults to whatever the user has configured in their browser (often 16 px, but low-vision users frequently set it higher). All typography and spacing tokens should be `rem`-based. Tailwind's defaults already are. Use `px` only for things that genuinely shouldn't scale: 1 px borders, focus ring offsets, image dimensions.

**Incorrect (text and spacing in px — ignores user's browser settings):**

```tsx
<article style={{ fontSize: '14px', padding: '16px' }}>
  <h1 style={{ fontSize: '24px', marginBottom: '8px' }}>Title</h1>
  <p style={{ fontSize: '14px', lineHeight: '20px' }}>Paragraph</p>
</article>
```

**Correct (rem-based text via Tailwind tokens):**

```tsx
<article className="text-sm p-4">
  <h1 className="text-2xl font-semibold mb-2">Title</h1>
  <p className="text-sm leading-relaxed">Paragraph</p>
</article>
```

**Tailwind unit conventions:**

```text
text-*              → rem (responsive to user setting)
p-*, m-*, gap-*     → rem (responsive)
size-*, h-*, w-*    → rem (responsive)
border-*            → px  (intentional — 1px hairlines stay crisp)
ring-*, outline-*   → px  (intentional)
```

**Defining custom rem values:**

```css
/* app/globals.css */
@theme {
  --spacing: 0.25rem; /* Tailwind's spacing unit */
  --text-2xs: 0.625rem;
  --text-display: 4rem;
  /* 1rem === user's preferred body text size; everything scales together */
}
```

**Don't force `html { font-size: 14px }`:**

```css
/* INCORRECT — overrides the user's setting */
html { font-size: 14px; }

/* CORRECT — leave it alone, scale your design with rem multiples */
```

**When `px` IS the right unit:**

```tsx
<div className="border border-border" />  {/* 1px hairline — should stay 1px */}
<img width={64} height={64} src="..." />   {/* image intrinsic size */}
<svg width="20" height="20">...</svg>      {/* icon viewBox — pair with size-5 Tailwind class */}
```

**Rule:**
- Default to `rem` for text, padding, margin, gap, width/height of text containers
- Never hardcode `font-size: Npx` — use Tailwind text utilities or `rem` values
- Don't override `html { font-size }` — it scales the user's settings against them
- Use `px` only for: borders, focus offsets, image intrinsic dimensions, SVG viewBox
- Test by changing browser default text size (Chrome → Settings → Appearance → Font size → Very Large) and verifying the UI scales

Reference: [Use rem instead of px — Josh W Comeau](https://www.joshwcomeau.com/css/surprising-truth-about-pixels-and-accessibility/)
