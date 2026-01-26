---
title: Profile Build Performance
impact: LOW-MEDIUM
impactDescription: pinpoints 80% of bottlenecks
tags: advanced, profiling, debugging, performance
---

## Profile Build Performance

Use Vite's built-in profiling to identify specific performance bottlenecks in your build pipeline.

**Incorrect (guessing at performance issues):**

```javascript
// vite.config.js
export default defineConfig({
  // "Build feels slow"
  // Randomly trying optimizations
  // No data to guide decisions
})
```

**Correct (data-driven profiling):**

```bash
# Generate CPU profile
vite build --profile
# Creates vite-profile-0.cpuprofile
```

```javascript
// vite.config.js
import Inspect from 'vite-plugin-inspect'

export default defineConfig({
  plugins: [
    Inspect()  // Visit /__inspect in dev
  ]
})
// See exactly which plugins take time
```

**Debug plugin transforms:**

```bash
# See transform times per file
vite --debug plugin-transform

# Example output:
# 10:32:15 [vite] ✓ transform (23ms) src/App.tsx
# 10:32:15 [vite] ✓ transform (156ms) src/HeavyComponent.tsx  ← bottleneck
```

**Analyze with speedscope:**

1. Upload `.cpuprofile` to https://www.speedscope.app
2. Look for wide bars (long-running operations)
3. Identify plugin names in stack traces

**Fix common issues:**
- Slow plugin → lazy import dependencies
- Many transforms → add file filters
- Large modules → dynamic imports

Reference: [Performance | Vite](https://vite.dev/guide/performance)
