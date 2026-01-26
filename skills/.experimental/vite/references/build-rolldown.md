---
title: Consider Rolldown for Faster Builds
impact: MEDIUM-HIGH
impactDescription: 2-10× faster builds (experimental)
tags: build, rolldown, rollup, experimental
---

## Consider Rolldown for Faster Builds

Rolldown is a Rust-based Rollup replacement that unifies Vite's dev and build tooling. It's experimental but offers significant performance improvements.

**Incorrect (separate tools with inconsistencies):**

```javascript
// vite.config.js
export default defineConfig({
  // Current architecture:
  // Dev:   esbuild (pre-bundling) + native ESM
  // Build: Rollup (bundling) + esbuild (minification)
  // Behavior can differ between dev and prod
})
```

**Correct (unified Rolldown bundler):**

```javascript
// vite.config.js
export default defineConfig({
  builder: {
    name: 'rolldown'  // Experimental
  }
})
// Same bundler for dev and build
// Consistent behavior, faster builds
```

**Benefits:**
- 2-10× faster builds (Rust performance)
- Consistent behavior dev ↔ build
- Better tree-shaking

**Current limitations:**
- Experimental status
- Some Rollup plugins may not work
- API differences in edge cases

**When to try Rolldown:**
- Greenfield projects
- Build time is a significant pain point
- Willing to test experimental features

**When to wait:**
- Production critical applications
- Heavy reliance on Rollup plugins

Reference: [Rolldown Integration](https://vite.dev/guide/rolldown)
