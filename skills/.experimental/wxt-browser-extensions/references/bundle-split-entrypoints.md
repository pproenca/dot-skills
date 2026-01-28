---
title: Split Code by Entrypoint
impact: MEDIUM-HIGH
impactDescription: reduces initial load time by 30-50%
tags: bundle, code-splitting, entrypoints, lazy-loading
---

## Split Code by Entrypoint

Each WXT entrypoint (background, popup, content script) should only import what it needs. Shared code between entrypoints bloats all bundles.

**Incorrect (shared heavy imports):**

```typescript
// utils/index.ts - barrel file with everything
export { formatDate, parseDate } from './dates'
export { fetchAPI, processResponse } from './api'
export { renderChart, ChartConfig } from './charts' // Heavy charting library

// popup.ts - only needs dates, but gets charts too
import { formatDate } from '@/utils'

// content.ts - only needs api, but gets charts too
import { fetchAPI } from '@/utils'
```

**Correct (entrypoint-specific imports):**

```typescript
// utils/dates.ts
export { formatDate, parseDate }

// utils/api.ts
export { fetchAPI, processResponse }

// utils/charts.ts - only imported where needed
export { renderChart, ChartConfig }

// popup.ts - imports only dates
import { formatDate } from '@/utils/dates'

// content.ts - imports only api
import { fetchAPI } from '@/utils/api'

// options.ts - imports charts when needed
import { renderChart } from '@/utils/charts'
```

**Alternative (dynamic imports for heavy deps):**

```typescript
// popup.ts
async function showAnalytics() {
  // Only load charts library when user opens analytics
  const { renderChart } = await import('@/utils/charts')
  renderChart(container, data)
}
```

Reference: [WXT Build Configuration](https://wxt.dev/guide/essentials/config/build)
