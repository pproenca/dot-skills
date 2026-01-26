---
title: Analyze Bundle Composition
impact: CRITICAL
impactDescription: identifies 50-200KB hidden dependencies
tags: bundle, visualizer, analysis, debugging
---

## Analyze Bundle Composition

Use `rollup-plugin-visualizer` to understand what's in your bundle. Hidden large dependencies often cause unexpected bundle size.

**Incorrect (blind optimization):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    // "Bundle is too large"
    // No idea which dependencies are causing it
    // Random optimization attempts
  }
})
```

**Correct (data-driven analysis):**

```javascript
// vite.config.js
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    visualizer({
      open: true,
      filename: 'dist/stats.html',
      gzipSize: true,
      brotliSize: true
    })
  ]
})
```

```bash
# Run analysis
vite build
# Opens interactive treemap showing:
# - moment.js: 300KB (replace with date-fns)
# - lodash: 70KB (use named imports)
# - duplicate React versions: 200KB
```

**What to look for:**
- Unexpectedly large dependencies
- Duplicate packages (different versions)
- Unused code that should be tree-shaken
- Heavy dependencies that could be lazy-loaded

**Common findings and fixes:**
| Finding | Size | Fix |
|---------|------|-----|
| moment.js | 300KB | Replace with date-fns |
| lodash | 70KB | Named imports from lodash-es |
| Icon library | 500KB | Direct imports |

Reference: [Building for Production](https://vite.dev/guide/build)
