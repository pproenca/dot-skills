---
title: Tighten Letter Spacing for Headlines, Loosen for Uppercase
impact: MEDIUM
impactDescription: corrects optically unbalanced text at extreme sizes
tags: type, letter-spacing, tracking, headlines, uppercase
---

Large headlines look better with tighter letter spacing because default tracking appears too loose at large sizes. All-caps text needs wider letter spacing for readability since uppercase letters are designed to appear after lowercase letters.

**Incorrect (default tracking at all sizes):**
```html
<div class="space-y-4">
  <h1 class="text-5xl font-bold">Welcome Back</h1>
  <span class="text-xs font-semibold uppercase text-gray-500">FEATURED ARTICLE</span>
</div>
```

**Correct (tight headlines, wide uppercase):**
```html
<div class="space-y-4">
  <h1 class="text-5xl font-bold tracking-tight">Welcome Back</h1>
  <span class="text-xs font-semibold uppercase tracking-wide text-gray-500">Featured Article</span>
</div>
```

Reference: Refactoring UI — "Designing Text"
