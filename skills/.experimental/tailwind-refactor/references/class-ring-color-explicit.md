---
title: Add Explicit Ring Color for v4 Default Change
impact: HIGH
impactDescription: prevents rings changing from blue-500 to currentColor
tags: class, ring, color, default
---

## Add Explicit Ring Color for v4 Default Change

In Tailwind CSS v3, the `ring` utility implicitly set the ring color to `blue-500` at 50% opacity. In v4, the default ring color changed to `currentColor`, matching standard CSS behavior. This means any element using `ring` without an explicit color class will now inherit the text color as its ring color, which can produce a dramatically different appearance — especially on focus states.

**Incorrect (what's wrong):**

```html
<input class="ring focus:ring-2" />
<button class="focus:ring">Assumed blue ring</button>
```

**Correct (what's right):**

```html
<input class="ring ring-blue-500/50 focus:ring-2 focus:ring-blue-500/50" />
<button class="focus:ring focus:ring-blue-500/50">Explicit blue ring</button>
```

If your project uses a different brand color for focus rings, replace `blue-500/50` with the appropriate theme token.
