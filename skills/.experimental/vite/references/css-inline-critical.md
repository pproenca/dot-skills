---
title: Extract Critical CSS for Initial Paint
impact: MEDIUM
impactDescription: 200-500ms faster First Contentful Paint
tags: css, critical, performance, fcp
---

## Extract Critical CSS for Initial Paint

Critical CSS inlines styles needed for above-the-fold content, reducing render-blocking resources.

**Incorrect (all CSS blocks rendering):**

```html
<!-- index.html -->
<head>
  <link rel="stylesheet" href="/assets/styles.css">
  <!-- 500KB CSS blocks rendering -->
  <!-- User sees blank page for 2s -->
</head>
```

**Correct (critical CSS inlined):**

```html
<!-- index.html -->
<head>
  <!-- Critical CSS inlined -->
  <style>
    body { margin: 0; font-family: system-ui; }
    .header { height: 64px; background: #fff; }
    .hero { min-height: 400px; }
  </style>

  <!-- Non-critical CSS loaded async -->
  <link rel="preload" href="/assets/styles.css" as="style"
        onload="this.onload=null;this.rel='stylesheet'">
</head>
```

**Automated with plugin:**

```javascript
// vite.config.js
import critical from 'vite-plugin-critical'

export default defineConfig({
  plugins: [
    critical({
      criticalUrl: 'http://localhost:5173',
      criticalPages: [{ uri: '/', template: 'index' }],
      criticalConfig: {
        inline: true,
        dimensions: [
          { width: 375, height: 667 },
          { width: 1920, height: 1080 }
        ]
      }
    })
  ]
})
```

**Benefits:**
- Faster First Contentful Paint
- Reduced render-blocking
- Better Lighthouse scores

Reference: [Building for Production](https://vite.dev/guide/build)
