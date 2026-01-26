---
title: Use Lightning CSS Instead of PostCSS
impact: MEDIUM
impactDescription: 10-100× faster CSS transforms
tags: css, lightning-css, postcss, performance
---

## Use Lightning CSS Instead of PostCSS

Lightning CSS is a Rust-based CSS processor that's significantly faster than PostCSS for common transformations.

**Incorrect (slow PostCSS for basic transforms):**

```javascript
// vite.config.js
export default defineConfig({
  // PostCSS handles autoprefixer, nesting
  // 500ms+ per CSS file in large projects
})

// postcss.config.js
module.exports = {
  plugins: {
    autoprefixer: {},
    'postcss-nesting': {}
  }
}
```

**Correct (Lightning CSS):**

```javascript
// vite.config.js
export default defineConfig({
  css: {
    transformer: 'lightningcss'
  },
  build: {
    cssMinify: 'lightningcss'
  }
})
// Autoprefixer, nesting handled natively
// 10-100× faster transforms
```

**What Lightning CSS handles:**
- Autoprefixer (vendor prefixes)
- CSS nesting
- CSS modules
- Color function transforms
- Custom media queries

**When PostCSS is still needed:**

```javascript
// vite.config.js
export default defineConfig({
  css: {
    transformer: 'lightningcss'
    // PostCSS config still works for:
    // - TailwindCSS
    // - Custom PostCSS plugins
  }
})
```

Reference: [Features | Vite](https://vite.dev/guide/features)
