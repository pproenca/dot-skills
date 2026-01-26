---
title: Include Large Dependencies with Many Modules
impact: CRITICAL
impactDescription: 10-100× faster module resolution
tags: deps, pre-bundling, modules, optimization
---

## Include Large Dependencies with Many Modules

Packages with many internal modules (regardless of ESM/CJS format) should be included in pre-bundling. Without this, Vite makes hundreds of HTTP requests, causing slow initial loads.

**Incorrect (runtime discovery, 600+ requests):**

```javascript
// vite.config.js
export default defineConfig({
  // No optimizeDeps configuration
  // lodash-es has 600+ internal modules
  // Browser makes 600+ HTTP requests on first import
})
```

**Correct (pre-bundled into single module):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    include: [
      'lodash-es',   // 600+ ESM modules → 1 module
      'date-fns',    // Many ESM modules → 1 module
      'axios',       // CommonJS → converted to ESM
    ]
  }
})
```

**When to include:**
- **Many internal modules** (lodash-es, date-fns, rxjs) - reduces HTTP requests
- **CommonJS packages** - need ESM conversion for browser
- **Dynamic imports** not discoverable by static analysis

**When to exclude instead:**
- Small ESM packages with few modules
- Dependencies you're actively developing

Reference: [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling)
