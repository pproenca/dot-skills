---
title: Disable Source Maps in Production
impact: HIGH
impactDescription: reduces build time significantly
tags: build, sourcemaps, production, debugging
---

## Disable Source Maps in Production

Source map generation adds significant build time. Disable for production unless you need them for error tracking.

**Incorrect (always generating sourcemaps):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    sourcemap: true  // Adds 20-50% build time
  }
})
```

**Correct (environment-based):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    sourcemap: process.env.NODE_ENV !== 'production'
  }
})
```

**Hidden source maps (for error tracking):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    sourcemap: 'hidden'  // Generates .map files but no reference in bundles
  }
})
// Upload .map files to error tracking service
// Don't serve them publicly
```

**Options:**
| Value | Output | Use Case |
|-------|--------|----------|
| `false` | No maps | Production (fastest) |
| `true` | Inline + external | Development |
| `'inline'` | Inline only | Simple debugging |
| `'hidden'` | External only | Error tracking services |

**With error tracking:**
- Generate hidden sourcemaps
- Upload to Sentry/Datadog/etc.
- Delete from public deployment

Reference: [Build Options](https://vite.dev/config/build-options)
