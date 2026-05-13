---
title: Declare package-flat-export libraries in optimizePackageImports so the compiler tree-shakes them
impact: CRITICAL
impactDescription: 200-800ms faster imports per page, 50-80% smaller bundles for icon/utility libraries with hundreds of flat exports
tags: build, package-imports, tree-shaking, flat-export-library
---

## Declare package-flat-export libraries in optimizePackageImports so the compiler tree-shakes them

**Pattern intent:** libraries that ship a flat re-export surface (`lucide-react`, `@heroicons/react`, `@mui/icons-material`, `date-fns`, `lodash`) load *every* module when *any* named import is referenced, unless the bundler is told it's safe to pick out only what's used. The `optimizePackageImports` config does exactly that.

### Shapes to recognize

- `import { Menu } from 'lucide-react'` (or any other icon library) where `next.config.{js,ts}` does not list `lucide-react` in `experimental.optimizePackageImports`.
- A barrel file in the repo (`@/components/ui` or similar) that re-exports 50+ items, used from many call sites — pays the same cost.
- A `package.json` listing icon/utility libraries with no corresponding optimization config — every dev startup spends seconds resolving every export.
- A custom-built utility library inside the monorepo whose top-level export re-exports dozens of submodules — same problem.
- Workaround: importing from a deep path like `lucide-react/icons/Menu` — works for some libraries but not others, and the codebase splits between two conventions.

The canonical resolution: add the package(s) to `experimental.optimizePackageImports`. Next.js 16 ships defaults for the most common libraries; add custom ones.

Reference: [How we optimized package imports in Next.js](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)

**Incorrect (loads entire library):**

```typescript
// next.config.ts
const nextConfig = {
  // No optimization configured
}

// components/Header.tsx
import { Menu, X, Search } from 'lucide-react'
// Loads 1,583 modules, adds ~2.8s to dev startup
```

**Correct (loads only used icons):**

```typescript
// next.config.ts
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@heroicons/react', '@mui/icons-material']
  }
}

// components/Header.tsx
import { Menu, X, Search } from 'lucide-react'
// Loads only 3 modules (~2KB vs ~1MB)
```

**Note:** Next.js 16 automatically optimizes common libraries. Add custom libraries that export many modules.

Reference: [How we optimized package imports in Next.js](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
