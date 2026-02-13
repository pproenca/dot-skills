---
title: Update PostCSS Plugin to @tailwindcss/postcss
impact: CRITICAL
impactDescription: prevents 100% build failure — old plugin path removed in v4
tags: config, postcss, build-tooling, vite
---

## Update PostCSS Plugin to @tailwindcss/postcss

Tailwind CSS v4 ships its PostCSS integration as a separate package called `@tailwindcss/postcss`. The old `tailwindcss` package no longer exports a PostCSS plugin, so your build pipeline will break immediately unless the plugin reference is updated.

**Incorrect (what's wrong):**

```js
// postcss.config.js
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
```

**Correct (what's right):**

```js
// postcss.config.js
module.exports = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
```

For Vite projects, use the dedicated Vite plugin instead of PostCSS for better performance:

```js
// vite.config.js
import tailwindcss from "@tailwindcss/vite";

export default {
  plugins: [tailwindcss()],
};
```
