---
title: Externalize Dependencies for SSR
impact: MEDIUM
impactDescription: 2-5× faster SSR builds
tags: advanced, ssr, externalize, node
---

## Externalize Dependencies for SSR

For SSR, CommonJS dependencies can be externalized from Vite's transform system. This uses Node.js `require()` directly, improving both build and runtime performance.

**Incorrect (bundling all dependencies for SSR):**

```javascript
// vite.config.js
export default defineConfig({
  ssr: {
    noExternal: true  // Bundle everything
    // Transforms React, lodash, etc. unnecessarily
    // SSR bundle becomes huge
    // Build takes 10× longer
  }
})
```

**Correct (externalize CommonJS dependencies):**

```javascript
// vite.config.js
export default defineConfig({
  ssr: {
    external: ['react', 'react-dom', 'lodash'],
    noExternal: [
      '@my-org/ui-components',  // ESM-only, needs transform
      /\.css$/                   // CSS must be processed
    ]
  }
})
```

**Auto-externalize with exceptions:**

```javascript
// vite.config.js
export default defineConfig({
  ssr: {
    external: true,  // Externalize all node_modules
    noExternal: [
      // Only bundle packages that need transformation
      'esm-only-package',
      '@org/linked-package'
    ]
  }
})
```

**When to externalize:**
- CommonJS packages (react, lodash)
- Large dependencies
- Node.js native modules

**When to bundle (noExternal):**
- ESM-only packages without CJS build
- Linked workspace packages
- Packages with side-effect imports

Reference: [Server-Side Rendering](https://vite.dev/guide/ssr)
