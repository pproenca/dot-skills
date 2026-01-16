---
title: Import Only What You Use from Libraries
impact: CRITICAL
impactDescription: Prevents 50-500KB of dead code per library, 2-5x smaller vendor chunks
tags: bundle, tree-shaking, imports, dead-code-elimination
---

## Import Only What You Use from Libraries

Named imports from ESM-compatible libraries enable tree-shaking, but importing entire namespaces or using CommonJS patterns bundles everything. One careless import can add hundreds of kilobytes of unused code to your production build.

**Incorrect (imports prevent tree-shaking):**

```typescript
import * as lodash from 'lodash'
// Bundles entire 70KB library for one function

import Lodash from 'lodash'
const result = Lodash.debounce(handler, 300)
// Default import loads everything

import moment from 'moment'
// moment is not tree-shakeable, always loads 300KB+
```

**Correct (named imports enable tree-shaking):**

```typescript
import { debounce } from 'lodash-es'
// Only bundles debounce (~2KB) from ESM version

import debounce from 'lodash/debounce'
// Direct path import, guaranteed single function

import { format } from 'date-fns'
// date-fns is ESM, tree-shakes to only used functions
```

**Alternative (check bundle impact with analyzer):**

```typescript
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

module.exports = withBundleAnalyzer({
  // your config
})
```

```bash
ANALYZE=true npm run build
```

**Library substitutions for better tree-shaking:**
| Instead of | Use |
|------------|-----|
| `lodash` | `lodash-es` or direct imports |
| `moment` | `date-fns` or `dayjs` |
| `axios` | Native `fetch` |
| `uuid` | `crypto.randomUUID()` |
| `classnames` | `clsx` (smaller) |

**When NOT to apply:**
- Libraries that don't support ESM (check package.json for "module" field)
- When you genuinely use 50%+ of a library's exports

Reference: [Analyzing Bundle Size](https://nextjs.org/docs/app/guides/package-bundling#analyzing-javascript-bundles)
