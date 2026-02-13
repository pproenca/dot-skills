---
title: Update transition-[transform] to Individual Properties
impact: HIGH
impactDescription: prevents broken transition animations
tags: dep, transition, transform, animation
---

## Update transition-[transform] to Individual Properties

Tailwind CSS v4 uses individual CSS transform properties (`scale`, `rotate`, `translate`) instead of the composite `transform` property. When you specify `transition-[transform]` or include `transform` in a transition property list, it only animates the composite `transform` property -- but v4 utilities like `scale-*`, `rotate-*`, and `translate-*` set their own individual CSS properties, which will not be covered by that transition. You must reference the specific individual properties you want to animate.

**Incorrect (what's wrong):**

```html
<!-- transform is not the property being animated in v4 -->
<div class="transition-[opacity,transform] hover:scale-150 hover:opacity-0">
  Scale transition will not animate in v4
</div>
<button class="transition-transform hover:rotate-12">
  Rotation transition will not animate in v4
</button>
```

**Correct (what's right):**

```html
<!-- Reference the individual CSS properties that v4 actually uses -->
<div class="transition-[opacity,scale] hover:scale-150 hover:opacity-0">
  Scale transition animates correctly in v4
</div>
<button class="transition-[rotate] hover:rotate-12">
  Rotation transition animates correctly in v4
</button>
```
