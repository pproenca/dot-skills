---
title: Use cache() for Request Deduplication
impact: HIGH
impactDescription: eliminates duplicate fetches per render
tags: data, cache, deduplication, react
---

## Use cache() for Request Deduplication

Wrap data fetching functions with `cache()` to deduplicate identical calls within a single render tree. Multiple components can fetch the same data without duplicate requests.

**Incorrect (duplicate fetches):**

```typescript
// lib/data.ts
export async function getUser(id: string) {
  console.log('Fetching user', id)  // Logs multiple times!
  const res = await fetch(`/api/users/${id}`)
  return res.json()
}

// components/Header.tsx
async function Header() {
  const user = await getUser('123')  // Fetch #1
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
async function Sidebar() {
  const user = await getUser('123')  // Fetch #2 - duplicate!
  return <nav>{user.role === 'admin' && <AdminNav />}</nav>
}
```

**Correct (deduplicated with cache):**

```typescript
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  console.log('Fetching user', id)  // Logs once
  const res = await fetch(`/api/users/${id}`)
  return res.json()
})

// components/Header.tsx
async function Header() {
  const user = await getUser('123')  // Fetch
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
async function Sidebar() {
  const user = await getUser('123')  // Cached result reused
  return <nav>{user.role === 'admin' && <AdminNav />}</nav>
}
```

**With cacheSignal for cleanup (React 19.2):**

```typescript
import { cache, cacheSignal } from 'react'

const fetchWithCleanup = cache(async (url: string) => {
  const res = await fetch(url, { signal: cacheSignal() })
  return res.json()
})
// Fetch is automatically aborted if cache lifetime ends (render aborted/failed)
```

**Important:** `cache()` is for React Server Components only and requires framework support (e.g., Next.js) or React's canary channel. It is not available in standard client-side React setups. For client-side deduplication, use TanStack Query or SWR.

**Note:** `cache()` deduplicates within a single server request. For cross-request caching, use your framework's caching mechanism. `cacheSignal()` (React 19.2) provides an AbortSignal that fires when the cache lifetime ends.
