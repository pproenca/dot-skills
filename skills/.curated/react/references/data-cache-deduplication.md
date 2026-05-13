---
title: Per-request memoize data fetchers so multiple components reading the same data don't re-fetch
impact: HIGH
impactDescription: collapses N identical fetches in a render tree to one; eliminates the "log appears 4 times" smell
tags: data, request-memoization, per-request-cache, fetch-dedup
---

## Per-request memoize data fetchers so multiple components reading the same data don't re-fetch

**Pattern intent:** within a single server request, multiple Server Components that need the same data (e.g., the current user, a feature flag, a tenant config) should resolve from one fetch — not N copies. Wrap the fetcher with `cache()` at module scope.

### Shapes to recognize

- A `getUser(id)` function called from `Header.tsx`, `Sidebar.tsx`, and `Footer.tsx` — same id, three network calls.
- A `console.log('Fetching X')` that prints multiple times per page load — the fetcher is being called repeatedly with identical args.
- Multiple Server Components that each `await db.user.findUnique({ where: { id } })` for the *current* user during one render.
- A custom hook with module-level `const cache = new Map()` doing per-request dedup by hand — reinventing `react.cache`, missing the cleanup semantics and `cacheSignal`.
- A higher-order function that wraps fetchers in `useMemo` to dedupe — `useMemo` is per-component-instance, not per-request, so it doesn't help across components.

The canonical resolution: `export const getUser = cache(async (id) => { ... })`. Callers do not need to coordinate — React deduplicates by argument identity within the request boundary. For React 19.2, pair with `cacheSignal()` to abort the underlying fetch if the render is dropped.

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
