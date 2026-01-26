---
title: Configure Custom Entry Points for Discovery
impact: HIGH
impactDescription: prevents runtime discovery and full-page reloads
tags: deps, entries, discovery, configuration
---

## Configure Custom Entry Points for Discovery

Vite crawls HTML files by default to discover dependencies. For non-standard setups (SSR, library mode), configure `optimizeDeps.entries` to ensure complete discovery.

**Incorrect (missing entry points):**

```javascript
// vite.config.js
export default defineConfig({
  // Only crawls index.html
  // SSR entry and test files not discovered
  // Runtime discovery causes full-page reloads
})
```

**Correct (explicit entry points):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    entries: [
      'index.html',
      'src/server/entry.ts',     // SSR entry
      'src/**/*.spec.ts'         // Test files
    ]
  }
})
// All dependencies discovered at startup
// No runtime reloads
```

**When to configure entries:**
- SSR applications with separate server entries
- Library mode projects
- Projects with test files importing dependencies
- Non-HTML entry points (Web Workers)

**For monorepos:**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    entries: [
      'apps/web/index.html',
      'apps/admin/index.html',
      'packages/*/src/index.ts'
    ]
  }
})
```

Reference: [Dep Optimization Options](https://vite.dev/config/dep-optimization-options)
