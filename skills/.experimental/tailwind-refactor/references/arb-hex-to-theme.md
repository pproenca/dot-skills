---
title: Replace Arbitrary Hex Colors with Theme Tokens
impact: MEDIUM-HIGH
impactDescription: eliminates design drift across project
tags: arb, colors, theme, design-tokens
---

## Replace Arbitrary Hex Colors with Theme Tokens

Arbitrary hex values bypass the design system, cannot be found by searching for token names, and create visual inconsistency across the project. Every hardcoded color is a potential deviation from brand guidelines that grows harder to maintain over time.

**Incorrect (what's wrong):**

```html
<div class="bg-[#3b82f6] text-[#1e293b]">
  <p class="border-[#e2e8f0]">Hardcoded hex values scattered everywhere</p>
</div>
```

**Correct (what's right):**

```css
/* In your main CSS file */
@theme {
  --color-brand: #3b82f6;
  --color-heading: #1e293b;
  --color-border-subtle: #e2e8f0;
}
```

```html
<div class="bg-brand text-heading">
  <p class="border-border-subtle">Theme tokens are searchable and consistent</p>
</div>
```
