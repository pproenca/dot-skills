---
title: Analyze and Monitor Bundle Size
impact: MEDIUM-HIGH
impactDescription: identifies 2-10x bundle bloat from hidden dependencies
tags: bundle, analyze, size, wxt-build
---

## Analyze and Monitor Bundle Size

Use bundle analysis to identify unexpectedly large dependencies. Many npm packages include unnecessary code that dramatically increases extension size.

**Incorrect (blind dependency usage):**

```typescript
// Unknowingly importing 500KB+ from lodash barrel export
import { debounce } from 'lodash'

// Using a heavy charting library in a popup that only shows a number
import Chart from 'chart.js/auto'
```

**Correct (analyze with wxt build --analyze):**

```bash
# Analyze bundle size for each entrypoint
wxt build --analyze

# Open interactive treemap in browser
wxt build --analyze-open
```

```json
// package.json
{
  "scripts": {
    "build": "wxt build",
    "analyze": "wxt build --analyze-open"
  }
}
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

**Note:** Each WXT entrypoint (background, content scripts, popup) is a self-contained bundle. Unlike web apps, extension entrypoints cannot share code chunks because they run in separate contexts.

Reference: [WXT Build CLI](https://wxt.dev/api/cli/wxt-build)
