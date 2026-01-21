---
title: Avoid Barrel File Imports in App Router
impact: CRITICAL
impactDescription: 2-10× faster dev startup
tags: build, imports, barrel-files, tree-shaking
---

## Avoid Barrel File Imports in App Router

Barrel files (index.ts with re-exports) prevent tree-shaking and slow down development. Import directly from source files instead.

**Incorrect (imports through barrel file):**

```typescript
// lib/utils/index.ts (barrel file)
export * from './formatDate'
export * from './formatCurrency'
export * from './validateEmail'
// ... 50 more exports

// app/dashboard/page.tsx
import { formatDate } from '@/lib/utils'
// Loads all 50+ modules even though only formatDate is used
```

**Correct (direct import):**

```typescript
// app/dashboard/page.tsx
import { formatDate } from '@/lib/utils/formatDate'
// Loads only the formatDate module
```

**Alternative (path aliases):**

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/utils/*": ["./lib/utils/*"]
    }
  }
}

// app/dashboard/page.tsx
import { formatDate } from '@/utils/formatDate'
```

**Note:** If you must use barrel files, configure `optimizePackageImports` or use explicit named exports instead of `export *`.
