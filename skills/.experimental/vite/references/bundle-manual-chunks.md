---
title: Use manualChunks for Vendor Splitting
impact: CRITICAL
impactDescription: improves caching, reduces load time by 30-50%
tags: bundle, manualChunks, vendor, code-splitting
---

## Use manualChunks for Vendor Splitting

Split vendor dependencies into separate chunks for better caching. When your app code changes, vendor chunks stay cached in the browser.

**Incorrect (single vendor chunk):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            return 'vendor'  // All deps in one chunk
          }
        }
      }
    }
  }
})
// Any dep update invalidates entire vendor cache
```

**Correct (strategic vendor splitting):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            // React ecosystem (rarely changes)
            if (id.includes('react') || id.includes('react-dom') || id.includes('react-router')) {
              return 'react-vendor'
            }
            // Utility libraries
            if (id.includes('lodash') || id.includes('date-fns') || id.includes('axios')) {
              return 'utils-vendor'
            }
            // Heavy charting libs (load separately)
            if (id.includes('chart.js') || id.includes('recharts') || id.includes('d3')) {
              return 'chart-vendor'
            }
            return 'vendor'
          }
        }
      }
    }
  }
})
```

**Benefits:**
- React core cached long-term
- Utility updates don't invalidate React chunk
- Heavy libraries isolated for lazy loading

Reference: [Building for Production](https://vite.dev/guide/build)
