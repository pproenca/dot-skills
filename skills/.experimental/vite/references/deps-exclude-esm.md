---
title: Exclude Small ESM Dependencies
impact: CRITICAL
impactDescription: reduces pre-bundling overhead
tags: deps, esm, pre-bundling, exclude
---

## Exclude Small ESM Dependencies

Small dependencies that are already valid ESM should be excluded from pre-bundling. This lets the browser load them directly, reducing startup time.

**Incorrect (unnecessarily pre-bundling ESM):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    // Pre-bundling everything including tiny ESM packages
    include: ['tiny-esm-lib', 'small-util']
  }
})
```

**Correct (let browser handle small ESM):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    exclude: [
      'tiny-esm-lib',  // Already valid ESM, small
      'small-util'     // Browser can handle directly
    ]
  }
})
```

**When to exclude:**
- Small packages with few modules
- Packages already shipping valid ESM
- Dependencies you're actively developing (linked packages)

**When NOT to exclude:**
- Large packages with many internal modules
- CommonJS-only packages
- Packages causing "does not provide an export" errors

Reference: [Dep Optimization Options](https://vite.dev/config/dep-optimization-options)
