---
title: Pull data on the server with async/await — never `useEffect`+`fetch` in a Client Component
impact: CRITICAL
impactDescription: eliminates the HTML → JS → hydrate → fetch → render waterfall; ships data inside the initial HTML
tags: rsc, data-fetching, server-fetch, waterfall, no-client-fetch
---

## Pull data on the server with async/await — never `useEffect`+`fetch` in a Client Component

**Pattern intent:** data the page needs to render belongs in the server-side render. Fetching it on the client after hydration causes a four-stage waterfall (HTML → JS bundle → hydration → fetch → render) and ships unnecessary fetch code to the user.

### Shapes to recognize

- A `'use client'` component with `useEffect(() => { fetch(...).then(setData) }, [])` and a loading-skeleton conditional.
- A custom hook like `useUser(id)` whose body is `useState` + `useEffect` + `fetch` — same anti-pattern wrapped in a hook (also overlaps with `data-use-hook` and `cross-extract-shared-logic`).
- A SWR or react-query call in a Client Component for data that doesn't change after first load — moving it server-side eliminates a network round trip and ~30–80 KB of library code.
- The page tree has a Server Component parent that just passes data through to a Client Component, but the data could have been fetched at the leaf — the Server Component is doing nothing.
- "Skeleton flash → real content" flicker on every page load — a tell-tale waterfall symptom even when you can't see the code.

The canonical resolution: make the component a Server Component (drop `'use client'`, mark the function `async`, `await` the data directly). For interactivity nested inside, push `'use client'` down to a child leaf via composition.

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
