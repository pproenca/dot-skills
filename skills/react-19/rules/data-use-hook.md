---
title: Use the use() Hook for Promises in Render
impact: HIGH
impactDescription: cleaner async component code, Suspense integration
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

**Correct (use() with Suspense):**

```typescript
'use client'

import { use, Suspense } from 'react'

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise)  // Suspends until resolved
  return <Profile user={user} />
}

function UserPage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // Start fetch

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}
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

**Note:** `use()` can be called conditionally, unlike other hooks. It works in loops and conditionals.
