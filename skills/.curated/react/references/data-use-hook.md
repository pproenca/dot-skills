---
title: Read promises and conditional context with `use()` instead of `useEffect`+`useState` plumbing
impact: HIGH
impactDescription: removes the useEffect+useState fetch dance entirely; reads pre-resolved promises (created server-side) in render, integrates with Suspense
tags: data, use-hook, render-time-read, conditional-context
---

## Read promises and conditional context with `use()` instead of `useEffect`+`useState` plumbing

**Pattern intent:** when a component needs the value of a promise (or a context value conditionally), the read should happen in render — not via the effect-then-state dance. `use()` is the read primitive that lets Suspense and Error Boundaries handle the loading and failure cases.

### Shapes to recognize

- The classic `useState(null)` + `useEffect(() => { fetchX().then(setX) }, [])` + `if (!x) return null` triad — three lines doing what `const x = use(promise)` does in one.
- A custom hook named `useFoo` whose body is exactly that triad — same anti-pattern wrapped in a hook (see also `cross-extract-shared-logic`).
- A component reading a context value conditionally by branching outside `useContext` — `use(SomeContext)` reads conditionally; `useContext` can't.
- Workaround: a promise created *inside* a Client Component and passed to `use()` — recreated on every render, triggers infinite suspend. Create the promise in a Server Component (or stable cache) and pass it down.
- Workaround: nesting `await` inside a `useMemo` to "read once" — `useMemo` doesn't support async values; the result is undefined.

The canonical resolution: create the promise in a Server Component or stable scope; pass it as a prop; read with `const x = use(promise)` inside a Client Component wrapped in `<Suspense>`.

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

---

### In disguise — custom hook hiding the `useEffect`+`useState` fetch dance

The grep-friendly anti-pattern is `useState(null)` + `useEffect(() => { fetch(url).then(setX) }, [url])` written inline in a component. The same anti-pattern is most often *hidden inside a custom hook*, which makes it survive review — the hook looks like a clean reusable abstraction even though its body is the exact anti-pattern.

**Incorrect — in disguise (custom hook wrapping the same triad):**

```typescript
// hooks/useUser.ts — looks abstract and reusable
function useUser(id: string) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    setLoading(true)
    fetch(`/api/users/${id}`)
      .then((r) => r.json())
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [id])

  return { user, loading, error }
}

// Consumer
function UserProfile({ userId }: { userId: string }) {
  const { user, loading, error } = useUser(userId)
  if (loading) return <Skeleton />
  if (error) return <ErrorMessage />
  if (!user) return null
  return <Profile user={user} />
}
// The hook *is* the anti-pattern, just renamed. No Suspense integration,
// no error boundary integration, no abort safety, no caching across consumers.
```

This is also a candidate for [`cross-extract-shared-logic.md`](cross-extract-shared-logic.md) — if multiple files have written variants of this hook, they should converge on the canonical resolution.

**Correct — `use(promise)` in a Client Component, promise created server-side:**

```typescript
// page.tsx (Server Component) — creates a stable promise
import { Suspense } from 'react'

export default function UserPage({ params }: { params: { id: string } }) {
  const userPromise = fetchUser(params.id)
  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}

// UserProfile.tsx (Client Component)
'use client'
import { use } from 'react'

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise) // Suspends until resolved; throws to ErrorBoundary on failure
  return <Profile user={user} />
}
```

The hook disappears. The skeleton lives in the Suspense fallback. Errors land in the error boundary. The promise is stable because it was created in the Server Component.
