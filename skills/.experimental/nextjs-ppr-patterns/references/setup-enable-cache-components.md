---
title: Enable PPR with cacheComponents, not the removed experimental flags
tags: setup, cache-components, next-config, migration
---

## Enable PPR with cacheComponents, not the removed experimental flags

A model defaulting to Next.js 14/15 turns on Partial Prerendering with `experimental.ppr` in the config and `export const experimental_ppr = true` per route. **Both were removed in Next.js 16** — the config key is gone and the route export does nothing. PPR is now the default behavior of **Cache Components**, enabled once with the top-level `cacheComponents: true` (this also replaces the old `experimental.dynamicIO` flag). There is no per-route opt-in export anymore.

**Incorrect (Next.js 14/15 — removed in 16):**

```ts
// next.config.ts
const nextConfig = {
  experimental: { ppr: 'incremental' }, // removed
}

// app/dashboard/page.tsx
export const experimental_ppr = true // removed route export
```

**Correct (Next.js 16):**

```ts
// next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  cacheComponents: true, // PPR is the default behavior of Cache Components
}

export default nextConfig
```

Reference: [Next.js 16 — Cache Components](https://nextjs.org/blog/next-16#cache-components)
