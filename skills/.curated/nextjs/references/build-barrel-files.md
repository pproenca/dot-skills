---
title: Import from the source module, not from a barrel `index.ts` — barrel re-exports pessimize tree-shaking
impact: CRITICAL
impactDescription: 2-10× faster dev startup when barrel files in hot paths are replaced with direct imports
tags: build, barrel-file, direct-import, tree-shake
---

## Import from the source module, not from a barrel `index.ts` — barrel re-exports pessimize tree-shaking

**Pattern intent:** every import from a barrel file loads every module the barrel touches. In dev mode (where the bundler can't always prove unused exports are dead), one import becomes dozens of module loads. The fix is to import from the source file directly.

### Shapes to recognize

- `import { formatDate } from '@/lib/utils'` where `@/lib/utils/index.ts` is `export * from './formatDate'; export * from './formatCurrency'; ...` — every consumer pulls in everything.
- A `components/ui/index.ts` re-exporting 30+ components, consumed from every page — every page touches the full re-export graph.
- An *internal* package in a monorepo (`@org/ui`) whose root entry is a barrel — same problem at workspace scope.
- A barrel that does `export * from './x'` (worst — loads everything in `./x`) vs `export { a } from './x'` (still loads `./x` once but compilers can sometimes optimize).
- A barrel with side-effectful module imports — even setting `"sideEffects": false` doesn't always rescue you.
- Workaround: route everything through `optimizePackageImports` — works for *some* packages but not your own; better to fix the barrel.

The canonical resolution: import the file directly (`@/lib/utils/formatDate`) or set up TS path aliases that point at sources. For shared component libraries, prefer explicit per-component imports over a barrel.

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
