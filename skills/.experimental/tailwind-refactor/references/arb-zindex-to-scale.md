---
title: Replace Arbitrary z-index with a Defined Scale
impact: MEDIUM
impactDescription: prevents z-index arms race — 1 scale replaces N arbitrary values
tags: arb, z-index, layering, theme
---

## Replace Arbitrary z-index with a Defined Scale

Arbitrary z-index values create an escalation problem where developers keep adding higher numbers to "win" stacking battles. A defined scale prevents conflicts and documents the intended layering order for the entire application.

Note: z-index is not a theme-driven namespace in Tailwind v4, so `@theme` variables will not auto-generate `z-*` utilities. Instead, define CSS custom properties and reference them with the `z-(--var)` syntax, or create named utilities with `@utility`.

**Incorrect (what's wrong):**

```html
<div class="z-[999]">Dropdown</div>
<div class="z-[9999]">Modal</div>
<div class="z-[99999]">Toast — the arms race continues</div>
```

**Correct (what's right):**

Option A — CSS custom properties with `z-(--var)` syntax:

```css
:root {
  --z-dropdown: 50;
  --z-modal: 100;
  --z-toast: 150;
}
```

```html
<div class="z-(--z-dropdown)">Dropdown</div>
<div class="z-(--z-modal)">Modal</div>
<div class="z-(--z-toast)">Clear layering intent</div>
```

Option B — named utilities with `@utility`:

```css
@utility z-dropdown {
  z-index: 50;
}
@utility z-modal {
  z-index: 100;
}
@utility z-toast {
  z-index: 150;
}
```

```html
<div class="z-dropdown">Dropdown</div>
<div class="z-modal">Modal</div>
<div class="z-toast">Clear layering intent</div>
```
