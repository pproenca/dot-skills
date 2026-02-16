---
title: Separate Visual Hierarchy from Document Hierarchy
impact: HIGH
impactDescription: prevents h1-h6 tags from dictating visual design
tags: hier, semantics, html, headings, accessibility
---

HTML heading levels (h1-h6) exist for document structure and accessibility — not visual styling. An h3 in a sidebar shouldn't look the same as an h3 in the main content. Style headings based on visual importance, not tag level.

**Incorrect (heading tag dictates visual style):**
```html
<aside class="w-64">
  <h2 class="text-2xl font-bold">Related Articles</h2>
  <ul class="mt-4 space-y-2">
    <li><h3 class="text-xl font-bold">Getting Started</h3></li>
    <li><h3 class="text-xl font-bold">Advanced Tips</h3></li>
  </ul>
</aside>
```

**Correct (visual style matches context, not tag):**
```html
<aside class="w-64">
  <h2 class="text-xs font-semibold uppercase tracking-wide text-gray-500">Related Articles</h2>
  <ul class="mt-3 space-y-2">
    <li><h3 class="text-sm font-medium text-gray-700">Getting Started</h3></li>
    <li><h3 class="text-sm font-medium text-gray-700">Advanced Tips</h3></li>
  </ul>
</aside>
```

**Taste checkpoint:** After styling headings visually, verify that screen reader users still get a logical document outline. Visual hierarchy is for sighted users; heading levels are for assistive technology. Both must work independently. Empathy means designing for both at once.

Reference: Refactoring UI — "Hierarchy is Everything"
