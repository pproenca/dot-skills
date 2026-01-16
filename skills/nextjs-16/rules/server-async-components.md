---
title: Use async/await in Server Components
impact: HIGH
impactDescription: Direct data fetching eliminates useEffect boilerplate; reduces component code by 50% and removes loading state management complexity
tags: server, async, data-fetching, simplicity
---

## Use async/await in Server Components

Server Components support async/await directly at the component level. This eliminates useState/useEffect patterns for data fetching, resulting in cleaner code with fewer bugs and no client-side loading state management.

**Incorrect (client-side useEffect pattern):**

```typescript
'use client'

import { useEffect, useState } from 'react'

export default function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    let cancelled = false

    async function fetchUser() {
      try {
        const response = await fetch(`/api/users/${userId}`)
        if (!response.ok) throw new Error('Failed to fetch')
        const data = await response.json()
        if (!cancelled) setUser(data)
      } catch (e) {
        if (!cancelled) setError(e as Error)
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    fetchUser()
    return () => { cancelled = true }
  }, [userId])

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  if (!user) return null

  return <div>{user.name}</div>
}
```

**Correct (async Server Component):**

```typescript
// No 'use client' - Server Component
export default async function UserProfile({ userId }: { userId: string }) {
  const user = await fetch(`https://api.example.com/users/${userId}`, {
    next: { revalidate: 3600 }
  }).then(r => {
    if (!r.ok) throw new Error('Failed to fetch user')
    return r.json()
  })

  return <div>{user.name}</div>
}
```

**With error handling via error.tsx:**

```typescript
// app/users/[id]/page.tsx
export default async function UserPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const user = await getUser(id)  // Throws on error

  return <UserProfile user={user} />
}

// app/users/[id]/error.tsx
'use client'

export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <h2>Failed to load user</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

**With loading UI via loading.tsx:**

```typescript
// app/users/[id]/loading.tsx
export default function Loading() {
  return <UserProfileSkeleton />
}
```

**Benefits:**
- No useState/useEffect boilerplate
- No race condition handling
- No loading state management
- Error boundaries handle errors automatically
- Code is 50-70% shorter

**When NOT to use this pattern:**
- Data depends on client-side state (user interactions)
- Real-time data requiring WebSocket subscriptions

Reference: [Next.js Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching)
