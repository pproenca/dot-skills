---
title: Wrap each independently-paced async leaf in its own `<Suspense>` so fast content streams without waiting for slow tiles
impact: HIGH
impactDescription: dramatically faster Time to First Byte; the user sees the page shell and fast tiles immediately instead of waiting on the slowest fetch
tags: server, streaming, suspense-granularity, async-leaves
---

## Wrap each independently-paced async leaf in its own `<Suspense>` so fast content streams without waiting for slow tiles

**Pattern intent:** the page's loading experience should match the natural timing of its parts. A 100ms header should not be held hostage by a 2-second analytics widget. Each async subtree gets its own Suspense boundary; the framework streams each as it resolves.

### Shapes to recognize

- A single `Promise.all(...)` at the top of a `page.tsx` that gathers everything before returning JSX — page can't begin streaming until the slowest fetch lands.
- A `page.tsx` that fetches three independent things sequentially then renders one big tree — the user stares at a blank page (or the route-level `loading.tsx`) for the sum of latencies.
- A page-level `loading.tsx` as the *only* loading state — fine for navigation, does nothing for slow children once the page starts rendering.
- A `Suspense` at the route level wrapping everything — better than nothing, but blocks fast subtrees.
- Workaround: a `useEffect`/`useState` skeleton dance in a client component to "stream" a section — homemade streaming, brittler than `<Suspense>`.

The canonical resolution: identify each independently-paced async subtree; wrap each in `<Suspense fallback={<MatchingSkeleton/>}>`. The framework streams each as soon as it resolves.

**Incorrect (all-or-nothing rendering):**

```typescript
// app/page.tsx
export default async function Page() {
  const user = await fetchUser()           // 100ms
  const posts = await fetchPosts()         // 500ms
  const analytics = await fetchAnalytics() // 2000ms

  return (
    <div>
      <Header user={user} />
      <PostList posts={posts} />
      <Analytics data={analytics} />
    </div>
  )
}
// Nothing renders until analytics completes (2100ms)
```

**Correct (progressive streaming):**

```typescript
// app/page.tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <div>
      <Suspense fallback={<HeaderSkeleton />}>
        <Header />
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <PostList />
      </Suspense>
      <Suspense fallback={<AnalyticsSkeleton />}>
        <Analytics />
      </Suspense>
    </div>
  )
}

// Each component fetches its own data
async function Header() {
  const user = await fetchUser()
  return <header>{user.name}</header>
}

async function Analytics() {
  const data = await fetchAnalytics()
  return <AnalyticsChart data={data} />
}
// Header renders in 100ms, Posts in 500ms, Analytics in 2000ms
```

**Benefits:**
- First paint happens immediately
- Each section appears as soon as its data is ready
- Slow components don't block fast ones
