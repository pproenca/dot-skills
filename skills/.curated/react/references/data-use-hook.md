---
title: Use the use() Hook for Promises in Render
impact: HIGH
impactDescription: eliminates useEffect+useState fetch pattern, integrates with Suspense boundaries
tags: data, use, promises, async
---

## Use the use() Hook for Promises in Render

The `use()` hook reads values from Promises and Context during render. It integrates with Suspense for declarative loading states.

**Incorrect (useEffect for data fetching):**

```typescript
'use client'

import { useState, useEffect } from 'react'

function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchUser(userId).then(data => {
      setUser(data)
      setLoading(false)
    })
  }, [userId])

  if (loading) return <Skeleton />
  return <Profile user={user} />
}
```

**Correct (use() with promise from Server Component):**

```typescript
// Server Component — creates stable promise
import { Suspense } from 'react'

export default function UserPage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // Stable across re-renders

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}

// Client Component — reads the promise
'use client'

import { use } from 'react'

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise)  // Suspends until resolved
  return <Profile user={user} />
}
// Promise created in Server Component is stable across re-renders
```

**use() with Context (conditional reading):**

```typescript
import { use } from 'react'

function Button({ showTheme }: { showTheme: boolean }) {
  // Can read context conditionally - not possible with useContext
  if (showTheme) {
    const theme = use(ThemeContext)
    return <button className={theme.button}>Click</button>
  }
  return <button>Click</button>
}
```

**Important:** Never create promises inside Client Components and pass them to `use()` — they are recreated on every render, causing infinite suspense loops. Always create promises in Server Components or cache them.

**Note:** `use()` can be called conditionally, unlike other hooks. It works in loops and conditionals.
