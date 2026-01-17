---
title: Fetch Data in Server Components
impact: CRITICAL
impactDescription: 38% less client JS, no client waterfalls
tags: rsc, data-fetching, server, async
---

## Fetch Data in Server Components

Fetch data directly in Server Components using async/await. This eliminates client-side waterfalls and reduces JavaScript bundle size.

**Incorrect (client-side data fetching):**

```typescript
'use client'

import { useState, useEffect } from 'react'

export function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data)
        setLoading(false)
      })
  }, [userId])

  if (loading) return <Skeleton />
  return <Profile user={user} />
}
// Waterfall: HTML → JS → Hydrate → Fetch → Render
```

**Correct (Server Component data fetching):**

```typescript
// Server Component - no 'use client' directive
export async function UserProfile({ userId }: { userId: string }) {
  const user = await fetch(`https://api.example.com/users/${userId}`)
    .then(res => res.json())

  return <Profile user={user} />
}
// Single request, data in HTML, no client JS for fetching
```

**With loading state:**

```typescript
import { Suspense } from 'react'

export function UserProfileWrapper({ userId }: { userId: string }) {
  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userId={userId} />
    </Suspense>
  )
}

async function UserProfile({ userId }: { userId: string }) {
  const user = await getUser(userId)
  return <Profile user={user} />
}
```
