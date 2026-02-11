---
title: Enforce Bundle Size Budgets with Analysis Tools
impact: CRITICAL
impactDescription: prevents gradual bundle size regression
tags: bundle, budgets, ci, analysis
---

## Enforce Bundle Size Budgets with Analysis Tools

Without explicit size budgets, bundles grow 5-15% per quarter as developers add dependencies and features. By the time slowness is noticeable, the bundle is 2-3x larger than necessary. Per-route budgets caught in CI prevent this drift and make every size increase a conscious, reviewed decision.

**Incorrect (no size tracking, regressions go unnoticed):**

```tsx
// package.json — no size analysis, no budgets
{
  "scripts": {
    "build": "vite build"
  }
}

// vite.config.ts — no chunk analysis
import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [react()],
})
```

**Correct (size-limit enforces budgets in CI):**

```tsx
// package.json — size-limit checks on every PR
{
  "scripts": {
    "build": "vite build",
    "size": "size-limit",
    "analyze": "ANALYZE=true vite build"
  },
  "size-limit": [
    { "path": "dist/assets/index-*.js", "limit": "80 KB", "gzip": true },
    { "path": "dist/assets/vendor-*.js", "limit": "120 KB", "gzip": true },
    { "path": "dist/assets/admin-*.js", "limit": "60 KB", "gzip": true }
  ]
}

// vite.config.ts — visualizer for manual analysis
import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import { visualizer } from "rollup-plugin-visualizer"

export default defineConfig({
  plugins: [
    react(),
    process.env.ANALYZE === "true" &&
      visualizer({ open: true, gzipSize: true, template: "treemap" }),
  ],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ["react", "react-dom", "react-router-dom"],
        },
      },
    },
  },
})
```

Reference: [size-limit — Performance Budget Tool](https://github.com/ai/size-limit)
