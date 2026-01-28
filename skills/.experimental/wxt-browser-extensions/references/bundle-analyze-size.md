---
title: Analyze and Monitor Bundle Size
impact: MEDIUM-HIGH
impactDescription: identifies 2-10× bundle bloat from hidden dependencies
tags: bundle, analyze, size, vite, rollup
---

## Analyze and Monitor Bundle Size

Use bundle analysis to identify unexpectedly large dependencies. Many npm packages include unnecessary code that dramatically increases extension size.

**Incorrect (blind dependency usage):**

```typescript
// wxt.config.ts
export default defineConfig({
  // No bundle analysis configured
})

// Unknowingly importing 500KB+ from lodash
import { debounce } from 'lodash'
```

**Correct (bundle analysis enabled):**

```typescript
// wxt.config.ts
import { defineConfig } from 'wxt'

export default defineConfig({
  vite: () => ({
    build: {
      rollupOptions: {
        output: {
          manualChunks: (id) => {
            // Log large dependencies during build
            if (id.includes('node_modules')) {
              const match = id.match(/node_modules\/(.+?)\//);
              return match ? `vendor/${match[1]}` : 'vendor'
            }
          }
        }
      }
    }
  })
})
```

```bash
# Add to package.json scripts
"analyze": "wxt build --analyze"
```

**Use lightweight alternatives:**

```typescript
// Instead of lodash (500KB+)
import debounce from 'lodash.debounce' // 2KB

// Instead of moment (300KB+)
import { formatDistance } from 'date-fns' // 15KB tree-shaken

// Instead of axios (40KB)
// Use native fetch with a tiny wrapper
```

**Bundle size targets:**
- Background: < 100KB
- Content script: < 50KB per script
- Popup/Options: < 200KB

Reference: [Vite Bundle Analysis](https://vitejs.dev/guide/build.html#library-mode)
