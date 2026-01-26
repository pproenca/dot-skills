---
title: Configure Asset Inlining Threshold
impact: MEDIUM
impactDescription: reduces HTTP requests by 10-50
tags: bundle, assets, inlining, base64
---

## Configure Asset Inlining Threshold

Vite inlines assets smaller than 4KB as base64 URLs. Adjust this threshold based on your asset profile to balance HTTP requests vs bundle size.

**Incorrect (too low threshold, many requests):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    assetsInlineLimit: 0  // No inlining
  }
})
// 50 tiny icons = 50 HTTP requests
// Slow on high-latency connections
```

**Correct (balanced threshold):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    assetsInlineLimit: 4096  // 4KB default
  }
})
// Small icons inlined as data URLs
// Reduces requests without bloating JS
```

**Fine-grained control:**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    assetsInlineLimit: (filePath, content) => {
      // Always inline SVG icons
      if (filePath.endsWith('.svg') && content.length < 10000) {
        return true
      }
      // Never inline photos
      if (/\.(png|jpg|gif)$/.test(filePath)) {
        return false
      }
      return content.length < 4096
    }
  }
})
```

**Considerations:**
- Inlined assets can't be cached separately
- Large base64 strings increase JS parse time
- Many separate files = many requests (less impact with HTTP/2)

Reference: [Build Options](https://vite.dev/config/build-options)
