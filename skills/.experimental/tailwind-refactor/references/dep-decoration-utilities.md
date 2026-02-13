---
title: Replace decoration-slice/clone with box-decoration-*
impact: CRITICAL
impactDescription: prevents build failures on 2 deprecated utilities
tags: dep, decoration, box-decoration, layout
---

## Replace decoration-slice/clone with box-decoration-*

The `decoration-slice` and `decoration-clone` utilities have been removed in Tailwind CSS v4. They are replaced by `box-decoration-slice` and `box-decoration-clone`, which more clearly map to the underlying `box-decoration-break` CSS property and avoid naming collisions with text decoration utilities.

**Incorrect (what's wrong):**

```html
<span class="decoration-slice bg-gradient-to-r from-indigo-500 to-pink-500">
  Multi-line highlighted text
</span>
<span class="decoration-clone bg-blue-500 px-2">
  Cloned box decoration
</span>
```

**Correct (what's right):**

```html
<span class="box-decoration-slice bg-gradient-to-r from-indigo-500 to-pink-500">
  Multi-line highlighted text
</span>
<span class="box-decoration-clone bg-blue-500 px-2">
  Cloned box decoration
</span>
```
