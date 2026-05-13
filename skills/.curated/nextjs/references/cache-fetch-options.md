---
title: Make every server `fetch` declare its caching intent — never let the default behavior be the documentation
impact: HIGH
impactDescription: controls per-request data freshness explicitly; eliminates "why is this stale?"/"why is this slow?" cascades from invisible defaults
tags: cache, fetch-options, explicit-cache-mode, no-store-vs-force-cache
---

## Make every server `fetch` declare its caching intent — never let the default behavior be the documentation

**Pattern intent:** every `fetch` in a Server Component or server function should declare what it wants — `cache: 'no-store'` for live data, `cache: 'force-cache'` for static, `next: { revalidate: N }` for time-based, or `next: { tags: [...] }` for tag-based. Leaving it implicit means the answer to "is this cached?" is "go read the framework changelog for the version we're on."

### Shapes to recognize

- A `fetch(...)` without any cache/revalidate/tags option in a Server Component — the intent is invisible to anyone reading it.
- A user-specific fetch (`fetch(\`/api/users/${userId}\`)`) without `cache: 'no-store'` — quietly returns stale data for the wrong user after the first request.
- A "config" fetch (`fetch(\`/api/config\`)`) without `force-cache` or a `revalidate` — hits upstream on every render.
- Two fetches to the same upstream endpoint with different cache settings in different files — divergent freshness, hard-to-diagnose bugs.
- A `fetch` whose URL contains a `?_=${Date.now()}` cache-buster — manual cache invalidation, doing what Next.js's cache controls would do declaratively.
- A workaround `headers: { 'Cache-Control': 'no-cache' }` instead of `cache: 'no-store'` — works for the upstream but doesn't tell Next.js the response is uncacheable.

The canonical resolution: pick the right mode for each fetch and make it explicit. Decision tree: per-user/real-time → `no-store`; semi-dynamic → `next: { revalidate }`; truly static → `force-cache`; on-demand invalidation → `next: { tags }`.

**Incorrect (mixing cache strategies without intent):**

```typescript
export default async function Page() {
  // Static data that rarely changes - correct
  const config = await fetch('https://api.example.com/config')

  // User-specific data that should be fresh - WRONG
  const user = await fetch(`https://api.example.com/users/${userId}`)
  // Using default caching for dynamic data!
}
```

**Correct (explicit cache strategies):**

```typescript
export default async function Page() {
  // Static data - cache indefinitely
  const config = await fetch('https://api.example.com/config', {
    cache: 'force-cache'
  })

  // Dynamic data - never cache
  const user = await fetch(`https://api.example.com/users/${userId}`, {
    cache: 'no-store'
  })

  // Semi-dynamic - revalidate every 5 minutes
  const products = await fetch('https://api.example.com/products', {
    next: { revalidate: 300 }
  })

  // Tagged for on-demand revalidation
  const posts = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] }
  })
}
```

**Cache strategy decision tree:**
- User-specific or real-time → `no-store`
- Changes hourly/daily → `next: { revalidate: N }`
- Static/rarely changes → `force-cache`
- Needs on-demand invalidation → `next: { tags: [...] }`
