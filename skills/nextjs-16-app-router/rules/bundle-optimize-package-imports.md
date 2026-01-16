---
title: Configure optimizePackageImports in next.config.js
impact: CRITICAL
impactDescription: Reduces compile time by 50-80%, eliminates 100KB-500KB of unused code per library
tags: bundle, next-config, optimizePackageImports, tree-shaking
---

## Configure optimizePackageImports in next.config.js

The `optimizePackageImports` option transforms barrel file imports into direct imports at build time. This eliminates the need to manually rewrite imports while achieving the same tree-shaking benefits, significantly improving both dev server startup and production bundle size.

**Incorrect (no optimization configured):**

```typescript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Missing optimizePackageImports - barrel imports load entire libraries
}

module.exports = nextConfig
```

```typescript
// components/Dashboard.tsx
import { BarChart, LineChart } from 'recharts'
import { format, addDays } from 'date-fns'
import { Settings, User, Bell } from 'lucide-react'
// Each import loads the ENTIRE library without optimization
```

**Correct (optimizePackageImports configured):**

```typescript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: [
      'recharts',
      'date-fns',
      'lucide-react',
      '@heroicons/react',
      'lodash-es',
      '@radix-ui/react-icons',
    ],
  },
}

module.exports = nextConfig
```

```typescript
// components/Dashboard.tsx - same imports, now auto-optimized
import { BarChart, LineChart } from 'recharts'
import { format, addDays } from 'date-fns'
import { Settings, User, Bell } from 'lucide-react'
// Build transforms these to direct imports automatically
```

**Libraries already optimized by Next.js (no config needed):**
- `@mui/material`, `@mui/icons-material`
- `@headlessui/react`
- `@tanstack/react-query`
- `rxjs`
- `ramda`

**Benefits:**
- Developer convenience of barrel imports with tree-shaking performance
- Faster dev server compilation (50-80% improvement)
- Smaller production bundles without manual import rewrites
- Turbopack performs this optimization automatically

Reference: [optimizePackageImports](https://nextjs.org/docs/app/api-reference/config/next-config-js/optimizePackageImports)
