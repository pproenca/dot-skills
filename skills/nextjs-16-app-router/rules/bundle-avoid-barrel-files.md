---
title: Import Directly from Source, Not Barrel Files
impact: CRITICAL
impactDescription: 200-800ms faster cold starts, prevents loading 10-100x more code than needed
tags: bundle, imports, barrel-files, tree-shaking
---

## Import Directly from Source, Not Barrel Files

Barrel files (index.ts re-exports) defeat tree-shaking by forcing bundlers to evaluate entire module graphs. A single import from a barrel file can pull in hundreds of unused components, destroying bundle performance.

**Incorrect (imports entire component library):**

```typescript
import { Button, Card, Modal } from '@/components'
// Loads ALL 50+ components from components/index.ts

import { formatDate, parseISO } from 'date-fns'
// Pulls in entire date-fns library (200KB+)

import { UserIcon, HomeIcon } from 'lucide-react'
// Loads all 1000+ icons into bundle
```

**Correct (direct imports enable tree-shaking):**

```typescript
import Button from '@/components/Button'
import Card from '@/components/Card'
import Modal from '@/components/Modal'

import { formatDate } from 'date-fns/formatDate'
import { parseISO } from 'date-fns/parseISO'

import { UserIcon } from 'lucide-react/dist/esm/icons/user'
import { HomeIcon } from 'lucide-react/dist/esm/icons/home'
```

**Alternative (configure optimizePackageImports):**

```typescript
// next.config.js - auto-transforms barrel imports at build time
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ['date-fns', 'lucide-react', '@/components'],
  },
}

module.exports = nextConfig
```

**Common barrel file offenders:**
- Icon libraries (lucide-react, @heroicons/react, react-icons)
- Date utilities (date-fns, dayjs with plugins)
- UI component libraries (internal component folders)
- Lodash (use lodash-es or direct imports)

Reference: [Package Bundling Optimization](https://nextjs.org/docs/app/guides/package-bundling)
