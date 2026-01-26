---
title: Address Large Chunk Warnings
impact: HIGH
impactDescription: indicates 2-5s load time problems
tags: bundle, chunks, warning, optimization
---

## Address Large Chunk Warnings

When Vite warns "Some chunks are larger than 500 kB", investigate and optimize. Large chunks hurt initial load time.

**Incorrect (ignore warning, raise limit):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    chunkSizeWarningLimit: 1000  // Just hiding the problem
    // Users still download 1MB+ on first visit
  }
})
```

**Correct (investigate and split):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            // Split heavy libs into separate chunks
            if (id.includes('react')) return 'react-vendor'
            if (id.includes('chart')) return 'chart-vendor'
            return 'vendor'
          }
        }
      }
    }
  }
})
```

**Optimization strategies:**

1. **Dynamic import heavy components:**
```typescript
const HeavyChart = lazy(() => import('./HeavyChart'))
```

2. **Replace large libraries:**
```javascript
// moment (300KB) → date-fns (tree-shakeable)
// lodash → lodash-es with named imports
```

3. **Check for duplicates** using bundle analyzer

**Acceptable to increase limit when:**
- Large chunks are lazy-loaded (not initial)
- You've optimized everything possible
- Application truly requires the dependency

Reference: [Build Options](https://vite.dev/config/build-options)
