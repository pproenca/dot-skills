---
title: Use React cache() for Request Deduplication
impact: HIGH
impactDescription: eliminates duplicate fetches within a single request
tags: server, cache, deduplication, data-fetching
---

## Use React cache() for Request Deduplication

When multiple Server Components need the same data, wrap the fetch function with `cache()` to deduplicate calls within a single request. Without caching, the same query runs multiple times.

**Incorrect (duplicate fetches per request):**

```tsx
// lib/data.ts
export async function getUser(id: string) {
  console.log('Fetching user...')  // Logs multiple times!
  return db.user.findUnique({ where: { id } })
}

// components/Header.tsx
export async function Header() {
  const user = await getUser(userId)  // First fetch
  return <nav>{user.name}</nav>
}

// components/Sidebar.tsx
export async function Sidebar() {
  const user = await getUser(userId)  // Second fetch - wasteful!
  return <aside>Welcome, {user.name}</aside>
}
```

**Correct (deduplicated with cache):**

```tsx
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  console.log('Fetching user...')  // Logs once per request
  return db.user.findUnique({ where: { id } })
})

// components/Header.tsx
export async function Header() {
  const user = await getUser(userId)  // Cached
  return <nav>{user.name}</nav>
}

// components/Sidebar.tsx
export async function Sidebar() {
  const user = await getUser(userId)  // Returns cached result
  return <aside>Welcome, {user.name}</aside>
}
```

**Note:** `cache()` creates a per-request cache. It does not persist across requests. For cross-request caching, use `unstable_cache` (Next.js) or a caching layer like Redis.

**When to use cache():**
- Database queries used in multiple components
- Expensive computations with the same inputs
- Any function called multiple times with same arguments per request

Reference: [React cache()](https://react.dev/reference/react/cache)
