---
title: Avoid Barrel File Imports
impact: CRITICAL
impactDescription: Barrel files can import 10,000+ unused modules; eliminating them reduces cold start by 200-800ms and bundle size by 100KB+
tags: bundle, barrel-files, imports, tree-shaking
---

## Avoid Barrel File Imports

Barrel files (`index.ts` re-exporting modules) force bundlers to evaluate all exports even when you need one. Icon libraries like `react-icons` or `@heroicons/react` can add thousands of unused icons to your bundle through a single import.

**Incorrect (barrel file import):**

```typescript
// Imports ALL icons, even though you use one
import { HomeIcon } from '@heroicons/react/24/outline'
// ^ This single import evaluates 300+ icon definitions

// Same problem with custom barrel files
import { Button } from '@/components'
// ^ Pulls in entire components/index.ts
```

```typescript
// components/index.ts (barrel file)
export * from './Button'
export * from './Card'
export * from './Modal'
export * from './Table'
export * from './Form'
// ... 50 more components
```

**Correct (direct imports):**

```typescript
// Direct import - only HomeIcon is bundled
import HomeIcon from '@heroicons/react/24/outline/HomeIcon'

// Direct import for your components
import { Button } from '@/components/Button'
```

**For external packages, use optimizePackageImports:**

```javascript
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: [
      '@heroicons/react',
      'lucide-react',
      '@radix-ui/react-icons',
      'date-fns',
      'lodash-es',
    ],
  },
}
```

**Turbopack note:**
Turbopack automatically analyzes and optimizes imports without configuration. If using Turbopack in development, these optimizations happen automatically.

**When NOT to use this pattern:**
- Small utility modules where all exports are typically used together
- When using Turbopack (optimizes automatically)
- When package is in `optimizePackageImports` config

Reference: [Vercel Blog - Barrel Files Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
