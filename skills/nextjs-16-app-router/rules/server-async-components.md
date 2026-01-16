---
title: Use Async/Await Directly in Server Components
impact: HIGH
impactDescription: eliminates useEffect waterfalls, enables streaming, removes client-side loading states
tags: server, async, data-fetching, streaming
---

## Use Async/Await Directly in Server Components

Server Components can be async functions, allowing direct await at the component level. This eliminates the useEffect + useState pattern that causes client-side waterfalls and flash of loading states. Data fetches complete before HTML is sent, improving perceived performance.

**Incorrect (client-side fetching pattern):**

```tsx
'use client'

import { useState, useEffect } from 'react'

export function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)  // Client sees loading spinner first

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data)
        setLoading(false)
      })
  }, [userId])  // Fetch starts AFTER hydration - waterfall

  if (loading) return <ProfileSkeleton />
  return <div>{user?.name}</div>
}
```

**Correct (async Server Component):**

```tsx
// No 'use client' - Server Component
import { getUser } from '@/lib/db'

export async function UserProfile({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetches during server render

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <p>Member since {user.createdAt.toLocaleDateString()}</p>
    </div>
  )
}
// HTML arrives with data already rendered
```

**Benefits:**
- Data fetches on server, closer to data source (lower latency)
- No loading spinner flash - content streams as ready
- Direct database/API access without exposing endpoints
- Automatic request deduplication with fetch cache

**When to still use client fetching:**
- User-initiated actions (search as you type)
- Real-time data (WebSocket connections)
- Data that changes based on client state

Reference: [Data Fetching in Server Components](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching)
