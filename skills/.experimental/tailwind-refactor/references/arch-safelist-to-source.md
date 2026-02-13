---
title: Replace safelist with @source inline()
impact: MEDIUM
impactDescription: replaces N-line JS safelist with 1 CSS directive
tags: arch, safelist, purge, source, v4-migration
---

## Replace safelist with @source inline()

The v3 `safelist` configuration in `tailwind.config.js` has been replaced by `@source inline()` in v4. The new directive lives in your CSS alongside other configuration, uses glob-like patterns for matching multiple classes, and eliminates the need for a JavaScript config file for this purpose.

**Incorrect (what's wrong):**

```js
// tailwind.config.js — v3 safelist
module.exports = {
  safelist: ['bg-red-500', 'bg-blue-500', /^text-/],
}
```

**Correct (what's right):**

```css
/* In your main CSS file — v4 @source inline() */
@source inline("bg-red-500 bg-blue-500 text-{red,blue,green}-{100,500,900}");
```
