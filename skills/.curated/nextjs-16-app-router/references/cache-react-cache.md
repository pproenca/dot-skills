---
title: Use React cache() for Request Deduplication
impact: HIGH
impactDescription: eliminates duplicate fetches per request
tags: cache, react-cache, deduplication, server-components
---

## Use React cache() for Request Deduplication

Wrap data fetching functions with `cache()` to deduplicate identical calls within a single render pass. Multiple components can call the same function without triggering multiple fetches.

**Incorrect (duplicate fetches):**

```typescript
// lib/data.ts
export async function getUser(id: string) {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
}

// components/Header.tsx
export async function Header({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetch #1
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
export async function Sidebar({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetch #2 - duplicate!
  return <nav>{user.role === 'admin' && <AdminLinks />}</nav>
}
```

**Correct (deduplicated with cache):**

```typescript
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
})

// components/Header.tsx
export async function Header({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetch
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
export async function Sidebar({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Cached result reused
  return <nav>{user.role === 'admin' && <AdminLinks />}</nav>
}
```

**Note:** React `cache()` deduplicates within a single request. For cross-request caching, use `unstable_cache` or the `'use cache'` directive.
