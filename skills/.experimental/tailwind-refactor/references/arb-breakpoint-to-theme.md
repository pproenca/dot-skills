---
title: Replace Arbitrary Breakpoints with @theme
impact: MEDIUM
impactDescription: reduces breakpoint duplication to 1 source of truth
tags: arb, breakpoints, responsive, theme
---

## Replace Arbitrary Breakpoints with @theme

Arbitrary breakpoints scatter responsive logic across files, making it impossible to see your responsive strategy at a glance. Defining breakpoints in `@theme` makes them searchable, reusable, and self-documenting. When a design changes its breakpoint boundary, you update one token instead of hunting through every template.

**Incorrect (what's wrong):**

```html
<div class="min-[1200px]:flex min-[1200px]:gap-4">
  <aside class="min-[1200px]:w-64">Repeated hardcoded breakpoint</aside>
</div>
```

**Correct (what's right):**

```css
@theme {
  --breakpoint-wide: 1200px;
}
```

```html
<div class="wide:flex wide:gap-4">
  <aside class="wide:w-64">Named breakpoint, one source of truth</aside>
</div>
```
