---
title: Don't Center Long-Form Text — Left-Align Body Content
impact: MEDIUM-HIGH
impactDescription: eliminates ragged-left edges that impair reading flow
tags: type, alignment, center, left-align, readability
---

Centered text works for short labels, headings, or hero sections. For anything longer than 2-3 lines, left-align. Center-aligned body text creates a ragged left edge that makes it hard to find the start of each line.

**Incorrect (centered paragraph text):**
```html
<div class="text-center">
  <h2 class="text-2xl font-bold">About Our Company</h2>
  <p class="mx-auto mt-4 max-w-2xl text-gray-600">We build tools that help developers create better software. Our mission is to simplify the development process and make it accessible to everyone, regardless of their experience level or background in programming.</p>
</div>
```

**Correct (centered heading, left-aligned body):**
```html
<div>
  <h2 class="text-center text-2xl font-bold">About Our Company</h2>
  <p class="mx-auto mt-4 max-w-2xl text-gray-600">We build tools that help developers create better software. Our mission is to simplify the development process and make it accessible to everyone, regardless of their experience level or background in programming.</p>
</div>
```

Reference: Refactoring UI — "Designing Text"
