---
title: Replace *-opacity-* Utilities with Opacity Modifiers
impact: CRITICAL
impactDescription: eliminates 6 deprecated utility families
tags: dep, opacity, color, bg, text, border
---

## Replace *-opacity-* Utilities with Opacity Modifiers

Tailwind CSS v4 removes all six standalone opacity utility families: `bg-opacity-*`, `text-opacity-*`, `border-opacity-*`, `divide-opacity-*`, `ring-opacity-*`, and `placeholder-opacity-*`. These utilities relied on CSS custom properties injected alongside the color utility and no longer exist in the v4 codebase. The modern replacement is the opacity modifier syntax (`/`), which is more concise, composable with arbitrary values, and works consistently across all color utilities.

**Incorrect (what's wrong):**

```html
<div class="bg-blue-500 bg-opacity-50">
<p class="text-red-600 text-opacity-75">
<div class="border border-gray-300 border-opacity-25">
<div class="divide-y divide-slate-200 divide-opacity-50">
<div class="ring ring-indigo-500 ring-opacity-30">
<input class="placeholder-gray-400 placeholder-opacity-60" placeholder="Search...">
```

**Correct (what's right):**

```html
<div class="bg-blue-500/50">
<p class="text-red-600/75">
<div class="border border-gray-300/25">
<div class="divide-y divide-slate-200/50">
<div class="ring ring-indigo-500/30">
<input class="placeholder-gray-400/60" placeholder="Search...">
```
