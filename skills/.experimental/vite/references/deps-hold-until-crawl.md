---
title: Configure holdUntilCrawlEnd for Startup Behavior
impact: HIGH
impactDescription: prevents mid-session reloads
tags: deps, discovery, crawl, experimental
---

## Configure holdUntilCrawlEnd for Startup Behavior

When Vite discovers new dependencies after initial load, it triggers a full-page reload. The `holdUntilCrawlEnd` option controls whether Vite waits for full discovery before optimizing.

**Incorrect (disabling wait causes more reloads):**

```javascript
// vite.config.js
export default defineConfig({
  optimizeDeps: {
    holdUntilCrawlEnd: false  // Don't wait for full crawl
    // Deps discovered after initial optimization cause reloads
  }
})
```

**Correct (default: wait for full discovery):**

```javascript
// vite.config.js
export default defineConfig({
  // holdUntilCrawlEnd: true is the default
  // Vite waits for all static imports to be discovered
  // Fewer mid-session reloads
})
```

**When to set `false`:**
- All dependencies are pre-identified in `include`
- You need fastest possible cold start
- Very large projects where crawl is slow

**Benefits of default `true`:**
- Eliminates mid-session full-page reloads
- More stable development experience
- Better for projects with dynamic imports

Reference: [Dep Optimization Options](https://vite.dev/config/dep-optimization-options)
