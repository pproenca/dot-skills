---
title: Handle Re-exports in Barrel Files
impact: MEDIUM-HIGH
impactDescription: detects unused items in export chains
tags: exports, barrel, reexports, aggregation
---

## Handle Re-exports in Barrel Files

Knip tracks re-exports through barrel files. Unused items in re-export chains are reported. Configure properly to avoid false positives.

**Incorrect (barrel file makes all exports appear used):**

```typescript
// src/index.ts
export * from './utils'
export * from './helpers'
export * from './constants'
```

All exports appear used because they're re-exported.

**Correct (use includeEntryExports for internal barrels):**

```json
{
  "includeEntryExports": true
}
```

Now Knip reports unused items even if re-exported.

**Trace re-export chain:**

```bash
knip --trace-export unusedHelper
```

Shows the re-export path:
```text
unusedHelper
  ← re-exported from src/helpers.ts
  ← re-exported from src/index.ts
  ← NOT imported elsewhere
```

**Auto-fix removes from chain:**

```bash
knip --fix-type exports
```

Removes unused items from re-export statements.

Reference: [Unused Exports](https://knip.dev/typescript/unused-exports)
