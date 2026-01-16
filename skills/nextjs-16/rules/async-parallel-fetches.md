---
title: Parallelize Independent Data Fetches
impact: CRITICAL
impactDescription: Reduces total fetch time from sum of all requests to longest single request (e.g., 3×200ms → 200ms)
tags: async, parallel, promise-all, waterfalls
---

## Parallelize Independent Data Fetches

Sequential await statements create waterfalls where each request waits for the previous one. When fetches are independent, running them in parallel with Promise.all() reduces total time to the duration of the slowest request.

**Incorrect (sequential waterfall):**

```typescript
export default async function Dashboard() {
  // Waterfall: 200ms + 150ms + 300ms = 650ms total
  const user = await fetch('/api/user').then(r => r.json())
  const posts = await fetch('/api/posts').then(r => r.json())
  const analytics = await fetch('/api/analytics').then(r => r.json())

  return (
    <div>
      <UserCard user={user} />
      <PostList posts={posts} />
      <Analytics data={analytics} />
    </div>
  )
}
```

**Correct (parallel fetches):**

```typescript
export default async function Dashboard() {
  // Parallel: max(200ms, 150ms, 300ms) = 300ms total
  const [user, posts, analytics] = await Promise.all([
    fetch('/api/user').then(r => r.json()),
    fetch('/api/posts').then(r => r.json()),
    fetch('/api/analytics').then(r => r.json()),
  ])

  return (
    <div>
      <UserCard user={user} />
      <PostList posts={posts} />
      <Analytics data={analytics} />
    </div>
  )
}
```

**Alternative (streaming with Suspense for better perceived performance):**

```typescript
import { Suspense } from 'react'

export default function Dashboard() {
  return (
    <div>
      <Suspense fallback={<UserCardSkeleton />}>
        <UserCard />
      </Suspense>
      <Suspense fallback={<PostListSkeleton />}>
        <PostList />
      </Suspense>
      <Suspense fallback={<AnalyticsSkeleton />}>
        <Analytics />
      </Suspense>
    </div>
  )
}
```

**When NOT to use this pattern:**
- When one fetch depends on the result of another (use sequential)
- When you want progressive loading with Suspense (split into separate components)

Reference: [Next.js Data Fetching Patterns](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching)
