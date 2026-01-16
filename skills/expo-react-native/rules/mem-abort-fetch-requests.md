---
title: Abort Fetch Requests on Component Unmount
impact: LOW-MEDIUM
impactDescription: prevents state updates on unmounted components
tags: mem, fetch, abort, async, cleanup
---

## Abort Fetch Requests on Component Unmount

Use AbortController to cancel in-flight fetch requests when components unmount. This prevents memory leaks and "setState on unmounted component" warnings.

**Incorrect (fetch continues after unmount):**

```typescript
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadUser = async () => {
      setLoading(true)
      const response = await fetch(`/api/users/${userId}`)
      const data = await response.json()
      setUser(data)  // May update unmounted component
      setLoading(false)
    }

    loadUser()
  }, [userId])

  if (loading) return <LoadingSpinner />
  return <ProfileCard user={user} />
}
// If user navigates away quickly, setState called on unmounted component
```

**Correct (aborts fetch on unmount):**

```typescript
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const abortController = new AbortController()

    const loadUser = async () => {
      setLoading(true)
      try {
        const response = await fetch(`/api/users/${userId}`, {
          signal: abortController.signal,
        })
        const data = await response.json()
        setUser(data)
        setLoading(false)
      } catch (error) {
        if (error.name !== 'AbortError') {
          console.error('Fetch failed:', error)
          setLoading(false)
        }
        // Ignore AbortError - expected on unmount
      }
    }

    loadUser()

    return () => abortController.abort()
  }, [userId])

  if (loading) return <LoadingSpinner />
  return <ProfileCard user={user} />
}
```

**With TanStack Query (handles automatically):**

```typescript
import { useQuery } from '@tanstack/react-query'

function UserProfile({ userId }) {
  const { data: user, isLoading } = useQuery({
    queryKey: ['user', userId],
    queryFn: async ({ signal }) => {
      const response = await fetch(`/api/users/${userId}`, { signal })
      return response.json()
    },
  })

  if (isLoading) return <LoadingSpinner />
  return <ProfileCard user={user} />
}
// TanStack Query handles abort automatically
```

**Custom hook for fetch with abort:**

```typescript
function useFetch(url) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    const controller = new AbortController()
    setLoading(true)

    fetch(url, { signal: controller.signal })
      .then(res => res.json())
      .then(setData)
      .catch(err => {
        if (err.name !== 'AbortError') setError(err)
      })
      .finally(() => setLoading(false))

    return () => controller.abort()
  }, [url])

  return { data, loading, error }
}
```

Reference: [AbortController MDN](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
