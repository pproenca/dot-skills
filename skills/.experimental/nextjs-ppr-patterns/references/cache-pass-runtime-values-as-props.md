---
title: Read runtime APIs outside the cache and pass values in as props
tags: cache, use-cache, cookies, runtime
---

## Read runtime APIs outside the cache and pass values in as props

To personalize a cached component, the model calls `cookies()` / `headers()` / `searchParams` inside the `'use cache'` function. That throws — a server-stored cached scope (`'use cache'` or `'use cache: remote'`) cannot read request APIs. (Passing the un-awaited Promise in instead is worse: the build hangs ~50s, then times out with a cache-fill error.) Read the runtime value in an *uncached* parent, then pass the plain value as an argument; it becomes part of the cache key, giving you one cached entry per value.

**Incorrect (request API inside a cached scope — throws):**

```tsx
async function Recommendations() {
  'use cache'
  const userId = (await cookies()).get('uid')?.value // not allowed inside use cache
  return <Carousel items={await getRecs(userId)} />
}
```

**Correct (read outside, pass the value in):**

```tsx
import { cookies } from 'next/headers'

async function RecommendationsSection() {
  const userId = (await cookies()).get('uid')?.value // runtime read in an uncached component
  return <Recommendations userId={userId} />
}

async function Recommendations({ userId }: { userId?: string }) {
  'use cache'
  // userId is part of the cache key → one entry per user
  return <Carousel items={await getRecs(userId)} />
}
```

**Alternative (`'use cache: private'`, experimental):** When moving the read out isn't practical, or compliance forbids storing the data server-side, the experimental `'use cache: private'` directive *can* read `cookies()`/`headers()`/`searchParams` inside the cached scope. But it caches only in the browser's memory (per-user, never stored on the server, requires a `cacheLife` with `stale` ≥ 30s) and is **not recommended for production**. Prefer passing values as props; reach for this only when you can't.

Reference: [use cache — request-time APIs constraint](https://nextjs.org/docs/app/api-reference/directives/use-cache#request-time-apis)
