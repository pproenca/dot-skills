---
title: Replace Arbitrary Spacing with Theme Scale
impact: MEDIUM-HIGH
impactDescription: maintains spacing consistency
tags: arb, spacing, theme, layout
---

## Replace Arbitrary Spacing with Theme Scale

Tailwind v4 supports any integer spacing value dynamically from the `--spacing` variable (e.g., `w-17`, `p-29`, `gap-13`), so most arbitrary pixel values are unnecessary. Only use arbitrary spacing when the exact pixel value is externally mandated (e.g., matching a third-party embed dimension).

**Incorrect (what's wrong):**

```html
<div class="p-[12px] mt-[28px] gap-[16px]">
  <section class="mb-[32px] px-[24px]">Hardcoded pixel values</section>
</div>
```

**Correct (what's right):**

```html
<div class="p-3 mt-7 gap-4">
  <section class="mb-8 px-6">Scale values from the spacing system</section>
</div>
```

**Important:** Only replace arbitrary values that exactly match a scale value (default: `N × 0.25rem`). If the pixel value does not align with the spacing scale (e.g., `p-[13px]`, `mt-[27px]`), replacing it with the nearest scale value will change the visual output. In such cases, either keep the arbitrary value or adjust the design to align with the scale first.

For truly custom spacing that repeats across the project, define it in `@theme`:

```css
@theme {
  --spacing-header: 72px;
  --spacing-sidebar: 280px;
}
```

```html
<header class="h-header">Consistent named spacing</header>
```
