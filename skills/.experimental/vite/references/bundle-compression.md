---
title: Disable Compressed Size Reporting for Large Projects
impact: MEDIUM-HIGH
impactDescription: 10-30 seconds faster builds
tags: bundle, compression, build-time, reporting
---

## Disable Compressed Size Reporting for Large Projects

By default, Vite calculates gzip sizes for all chunks. For large projects, this adds significant build time. Disable it when you don't need the information.

**Incorrect (always calculating compression):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    reportCompressedSize: true  // Default
  }
})
// Build output:
// dist/index.js    500 kB │ gzip: 150 kB  (10-30s to calculate)
// dist/vendor.js   800 kB │ gzip: 200 kB
```

**Correct (skip for faster builds):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    reportCompressedSize: false
  }
})
// Build output:
// dist/index.js    500 kB
// dist/vendor.js   800 kB
// Build completes 10-30s faster
```

**When to disable:**
- Large projects with many chunks
- CI/CD pipelines where build time matters
- When you measure compression separately

**When to keep enabled:**
- Small projects (minimal overhead)
- Debugging bundle size issues
- Need quick size feedback during development

Reference: [Build Options](https://vite.dev/config/build-options)
