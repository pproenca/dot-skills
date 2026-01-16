---
title: Tree-Shake Library Imports
impact: CRITICAL
impactDescription: Named imports from tree-shakeable packages reduce bundle by 70KB+ (e.g., lodash 70KB → lodash-es debounce 3KB)
tags: bundle, tree-shaking, imports, lodash
---

## Tree-Shake Library Imports

Import only the functions you need from libraries. CommonJS packages like `lodash` can't be tree-shaken and include everything. Use ES module alternatives (`lodash-es`) or direct file imports.

**Incorrect (entire library bundled):**

```typescript
import _ from 'lodash'  // 70KB+ bundled

export function processData(items: Item[]) {
  return _.chain(items)
    .filter(item => item.active)
    .sortBy('date')
    .value()
}
```

```typescript
import moment from 'moment'  // 67KB + locales

export function formatDate(date: Date) {
  return moment(date).format('MMMM D, YYYY')
}
```

**Correct (tree-shakeable imports):**

```typescript
import { filter, sortBy } from 'lodash-es'  // Only ~5KB for used functions

export function processData(items: Item[]) {
  return sortBy(filter(items, item => item.active), 'date')
}
```

```typescript
// Even better: direct path imports
import debounce from 'lodash-es/debounce'  // ~3KB
```

```typescript
// Use date-fns instead of moment
import { format } from 'date-fns'  // ~2KB for format

export function formatDate(date: Date) {
  return format(date, 'MMMM d, yyyy')
}
```

**Add to optimizePackageImports for automatic optimization:**

```javascript
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: [
      'lodash-es',
      'date-fns',
      'ramda',
      '@mui/material',
      '@mui/icons-material',
      'rxjs',
    ],
  },
}
```

**Common replacements:**

| Package | Size | Alternative | Size |
|---------|------|-------------|------|
| `lodash` | 70KB | `lodash-es` + direct | 3-5KB |
| `moment` | 67KB | `date-fns` | 2-10KB |
| `axios` | 13KB | `fetch` (native) | 0KB |
| `uuid` | 3KB | `crypto.randomUUID()` | 0KB |

**When NOT to use this pattern:**
- Package doesn't have ES module version
- Using nearly all exports anyway (rare)
- Bundle analyzer shows negligible impact

Reference: [Next.js Package Bundling](https://nextjs.org/docs/app/building-your-application/optimizing/package-bundling)
