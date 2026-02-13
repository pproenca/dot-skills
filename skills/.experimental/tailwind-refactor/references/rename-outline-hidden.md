---
title: Replace outline-none with outline-hidden
impact: HIGH
impactDescription: prevents accessibility regression
tags: rename, outline, focus, accessibility
---

## Replace outline-none with outline-hidden

In Tailwind CSS v4, `outline-none` now sets `outline-style: none`, which completely removes the focus outline for all users, including those navigating with a keyboard. This is an accessibility regression because Windows High Contrast Mode relies on visible outlines to indicate focus. The new `outline-hidden` utility uses a transparent outline that is invisible under normal rendering but remains visible in High Contrast Mode, preserving accessibility while achieving the same visual result.

**Incorrect (what's wrong):**

```html
<button class="focus:outline-none focus:ring-2 focus:ring-blue-500">
  Click me
</button>
```

**Correct (what's right):**

```html
<button class="focus:outline-hidden focus:ring-2 focus:ring-blue-500">
  Click me
</button>
```
