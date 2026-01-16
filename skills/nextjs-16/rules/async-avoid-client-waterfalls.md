---
title: Avoid Cascading useEffect Fetches
impact: CRITICAL
impactDescription: Each cascading useEffect adds one round-trip (100-300ms); 3 levels = 300-900ms of unnecessary latency
tags: async, useEffect, waterfalls, client-components
---

## Avoid Cascading useEffect Fetches

Nested useEffect calls that depend on each other create client-side waterfalls. Each level waits for the previous fetch to complete before starting, multiplying latency. Restructure to fetch on the server or parallelize where possible.

**Incorrect (cascading useEffect waterfall):**

```typescript
'use client'

import { useEffect, useState } from 'react'

export default function UserDashboard() {
  const [user, setUser] = useState(null)
  const [posts, setPosts] = useState([])
  const [comments, setComments] = useState([])

  // Level 1: fetch user (200ms)
  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser)
  }, [])

  // Level 2: fetch posts after user loads (200ms)
  useEffect(() => {
    if (user) {
      fetch(`/api/users/${user.id}/posts`).then(r => r.json()).then(setPosts)
    }
  }, [user])

  // Level 3: fetch comments after posts load (200ms)
  useEffect(() => {
    if (posts.length > 0) {
      const postIds = posts.map(p => p.id).join(',')
      fetch(`/api/comments?posts=${postIds}`).then(r => r.json()).then(setComments)
    }
  }, [posts])

  // Total: 600ms of sequential requests
  return <Dashboard user={user} posts={posts} comments={comments} />
}
```

**Correct (server-side data loading):**

```typescript
// Server Component - no useEffect needed
import { getUser, getUserPosts, getCommentsForPosts } from '@/lib/data'

export default async function UserDashboard() {
  const user = await getUser()

  // Parallel fetches where data dependencies allow
  const [posts, _] = await Promise.all([
    getUserPosts(user.id),
    // Other independent fetches...
  ])

  const comments = await getCommentsForPosts(posts.map(p => p.id))

  return <Dashboard user={user} posts={posts} comments={comments} />
}
```

**Alternative (when client-side is required, use single fetch):**

```typescript
'use client'

import useSWR from 'swr'

export default function UserDashboard() {
  // Single API call returns all needed data
  const { data } = useSWR('/api/dashboard', fetcher)

  if (!data) return <DashboardSkeleton />
  return <Dashboard {...data} />
}
```

**When NOT to use this pattern:**
- Data truly requires sequential client-side fetching (rare)
- Real-time updates where server fetch doesn't apply

Reference: [Vercel React Best Practices - Waterfalls](https://vercel.com/blog/introducing-react-best-practices)
