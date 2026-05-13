---
title: Wrap per-request fetchers with React `cache()` so calls from multiple Server Components in one render dedupe
impact: HIGH
impactDescription: collapses N identical fetches within a single render tree to one; eliminates the "log appears 4 times" smell
tags: cache, react-cache, request-dedup, per-render
---

## Wrap per-request fetchers with React `cache()` so calls from multiple Server Components in one render dedupe

**Pattern intent:** in a Server Component tree, multiple components (header, sidebar, page, footer) may each call `getUser(userId)`. Without `cache()`, each call is an independent fetch. With `cache()`, they all return the same in-render-memoized result.

### Shapes to recognize

- A `getX(id)` function called from multiple Server Components, each making its own fetch (visible as duplicate log lines per request).
- A `console.log('Fetching X')` printing multiple times per page load — the fetcher is being called repeatedly with identical args.
- Multiple components in one route tree calling `await db.user.findUnique({ where: { id } })` for the same id.
- A custom hook with module-level `const cache = new Map()` doing per-request dedup by hand — reinventing `react.cache`, plus you have to clear the map manually.
- A "data context" pattern that pre-fetches in a top-level layout and passes data down through props to avoid the duplicate fetch — works but pollutes the prop tree.

The canonical resolution: `export const getX = cache(async (id) => { ... })` at module scope. Callers don't need to coordinate. React dedupes by argument identity within the request boundary.

**Note on layering:** `react.cache` dedupes *within a request*. For *across requests*, layer it with `unstable_cache` or the `'use cache'` directive.

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
