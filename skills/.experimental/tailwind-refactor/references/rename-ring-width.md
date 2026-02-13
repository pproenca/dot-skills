---
title: Replace ring with ring-3 for v3 Default
impact: HIGH
impactDescription: prevents ring width changing from 3px to 1px
tags: rename, ring, focus, accessibility
---

## Replace ring with ring-3 for v3 Default

In Tailwind CSS v3, the bare `ring` utility generated a 3px ring. In v4, `ring` now produces a 1px ring, which is visually much thinner and may be imperceptible on some displays. If your design relied on the v3 default ring width, you must explicitly use `ring-3` to preserve the same appearance. Additionally, the default ring color changed from `blue-500` to `currentColor`, so verify ring colors are explicitly set where needed.

**Incorrect (what's wrong):**

```html
<button class="focus:ring ring-blue-500">
  Submit
</button>
```

**Correct (what's right):**

```html
<button class="focus:ring-3 ring-blue-500">
  Submit
</button>
```
