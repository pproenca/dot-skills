---
title: Replace @layer components with @utility
impact: MEDIUM
impactDescription: enables variant generation for custom utilities
tags: arch, utility, layer, v4-migration
---

## Replace @layer components with @utility

Styles defined in `@layer components` do not get automatic variant support in Tailwind v4. The `@utility` directive generates all variants automatically, making your custom classes behave exactly like built-in Tailwind utilities. This is most useful for single-purpose utilities where variant support matters. For multi-property component compositions, consider framework components instead.

**Incorrect (what's wrong):**

```css
/* @layer components — no variant support */
@layer components {
  .scrollbar-hidden {
    scrollbar-width: none;
    -ms-overflow-style: none;
  }
  .scrollbar-hidden::-webkit-scrollbar {
    display: none;
  }
}
```

```html
<!-- hover:scrollbar-hidden won't work -->
<div class="scrollbar-hidden overflow-y-auto">Scrollable content</div>
```

**Correct (what's right):**

```css
/* @utility — full variant support */
@utility scrollbar-hidden {
  scrollbar-width: none;
  -ms-overflow-style: none;
  &::-webkit-scrollbar {
    display: none;
  }
}
```

```html
<!-- All variants work automatically -->
<div class="hover:scrollbar-hidden overflow-y-auto">Show scrollbar, hide on hover</div>
```

**When NOT to use this pattern:**
- `@apply` cannot be used inside `@utility` blocks — use raw CSS properties only
- Multi-property component compositions (cards, buttons, etc.) are better as framework components than as `@utility` definitions
