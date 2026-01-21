---
title: Remove Redundant PostCSS Plugins
impact: HIGH
impactDescription: reduces plugin overhead, simplifies configuration
tags: build, postcss, plugins, configuration, optimization
---

## Remove Redundant PostCSS Plugins

Tailwind CSS v4's `@tailwindcss/postcss` plugin includes functionality that previously required separate plugins. Remove redundant plugins to simplify configuration and reduce build overhead.

**Incorrect (redundant plugins):**

```javascript
// postcss.config.js
export default {
  plugins: [
    "postcss-import",           // Now built-in
    "tailwindcss/nesting",      // Now built-in
    "@tailwindcss/postcss",
    "autoprefixer",             // Now built-in
  ],
};
```

**Correct (simplified configuration):**

```javascript
// postcss.config.js
export default {
  plugins: ["@tailwindcss/postcss"],
};
```

**Built-in functionality in v4:**
- `@import` processing (no postcss-import needed)
- CSS nesting (no tailwindcss/nesting needed)
- Vendor prefixing (no autoprefixer needed)

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
