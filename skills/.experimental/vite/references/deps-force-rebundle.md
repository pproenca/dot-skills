---
title: Use --force Flag for Dependency Changes
impact: CRITICAL
impactDescription: prevents stale cache issues
tags: deps, cache, force, debugging
---

## Use --force Flag for Dependency Changes

When modifying linked dependencies or troubleshooting pre-bundling issues, use the `--force` flag to clear the cache. Stale caches cause confusing behavior.

**Incorrect (using stale cache):**

```bash
# After modifying a linked dependency
npm run dev
# Changes not reflected due to cached pre-bundle
```

**Correct (force re-bundling):**

```bash
# Clear cache and re-bundle
vite --force

# Or configure in vite.config.js for debugging
```

```javascript
// vite.config.js (temporary for debugging)
export default defineConfig({
  optimizeDeps: {
    force: true  // Remove after debugging
  }
})
```

**When to use --force:**
- After modifying linked dependencies in a monorepo
- When seeing stale module behavior
- After changing `optimizeDeps.include` or `exclude`
- When debugging "module not found" errors

**Cache location:** `node_modules/.vite`

Reference: [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling)
