---
title: Stream Server Components for Progressive Loading
impact: HIGH
impactDescription: faster Time to First Byte, progressive rendering
tags: server, streaming, suspense, progressive-loading
---

## Stream Server Components for Progressive Loading

Split data-intensive Server Components and wrap them in Suspense to stream HTML progressively. Fast components render immediately while slow ones load.

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
