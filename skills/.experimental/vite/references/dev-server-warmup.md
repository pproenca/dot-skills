---
title: Warm Up Frequently Used Files
impact: MEDIUM-HIGH
impactDescription: eliminates transform latency for common files
tags: dev, warmup, pre-transform, startup
---

## Warm Up Frequently Used Files

Use `server.warmup` to pre-transform files that are always requested. This eliminates the transform latency on first load.

**Incorrect (cold transforms on first request):**

```javascript
// vite.config.js
export default defineConfig({
  // First request to App.tsx triggers transform
  // User sees delay on initial page load
})
```

**Correct (pre-transformed common files):**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    warmup: {
      clientFiles: [
        './src/App.tsx',
        './src/components/Layout.tsx',
        './src/hooks/useAuth.ts',
        './src/utils/api.ts'
      ]
    }
  }
})
```

**With SSR:**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    warmup: {
      clientFiles: ['./src/main.tsx'],
      ssrFiles: ['./src/entry-server.tsx']
    }
  }
})
```

**Find candidates to warm up:**

```bash
# See which files are transformed
vite --debug transform
# Add frequently appearing files to warmup list
```

**Benefits:**
- Faster initial page load
- Transforms happen during startup
- Better developer experience

Reference: [Performance | Vite](https://vite.dev/guide/performance)
