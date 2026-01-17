---
title: Configure optimizePackageImports for Icon Libraries
impact: CRITICAL
impactDescription: 200-800ms faster imports, 50-80% smaller bundles
tags: build, imports, tree-shaking, icons, turbopack
---

## Configure optimizePackageImports for Icon Libraries

Icon libraries like `lucide-react` export hundreds of modules. Without optimization, importing one icon loads the entire library. Configure `optimizePackageImports` to automatically tree-shake unused exports.

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
