---
title: Replace Arbitrary z-index with Theme Scale
impact: MEDIUM
impactDescription: prevents z-index conflicts
tags: arb, z-index, layering, theme
---

## Replace Arbitrary z-index with Theme Scale

Arbitrary z-index values create an escalation problem where developers keep adding higher numbers to "win" stacking battles. A defined scale prevents conflicts and documents the intended layering order for the entire application.

**Incorrect (what's wrong):**

```html
<div class="z-[999]">Dropdown</div>
<div class="z-[9999]">Modal</div>
<div class="z-[99999]">Toast — the arms race continues</div>
```

**Correct (what's right):**

```css
@theme {
  --z-dropdown: 50;
  --z-modal: 100;
  --z-toast: 150;
}
```

```html
<div class="z-dropdown">Dropdown</div>
<div class="z-modal">Modal</div>
<div class="z-toast">Clear layering intent</div>
```
