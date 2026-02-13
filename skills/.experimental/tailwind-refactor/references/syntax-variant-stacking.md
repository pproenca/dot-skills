---
title: Update Variant Stacking to Left-to-Right Order
impact: MEDIUM
impactDescription: prevents wrong variant application
tags: syntax, variants, v4-migration, selectors
---

## Update Variant Stacking to Left-to-Right Order

Tailwind v4 applies stacked variants left-to-right, matching CSS nesting order. In v3, variants applied right-to-left, which was counterintuitive. The new order reads naturally: each variant wraps the next, just like reading a sentence.

**Incorrect (what's wrong):**

```html
<!-- v3 right-to-left: "first child, then direct children" -->
<ul class="first:*:pt-0 last:*:pb-0">
  <li>Item</li>
</ul>
```

**Correct (what's right):**

```html
<!-- v4 left-to-right: "direct children, then first/last" — reads naturally -->
<ul class="*:first:pt-0 *:last:pb-0">
  <li>Item</li>
</ul>
```
