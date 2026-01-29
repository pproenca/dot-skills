---
title: Handle Async Actions with Loading and Error States
impact: MEDIUM-HIGH
impactDescription: prevents race conditions, improves UX
tags: update, async, loading, error-handling
---

## Handle Async Actions with Loading and Error States

Async actions should track loading and error states in the store. This prevents race conditions and provides UI feedback. Use try/catch and set states at the right moments.

**Incorrect (no loading or error handling):**

```typescript
const useUserStore = create<UserState>((set) => ({
  user: null,

  fetchUser: async (id: string) => {
    // No loading state, UI doesn't know fetch is in progress
    const response = await fetch(`/api/users/${id}`)
    const user = await response.json()
    set({ user })
    // Errors silently fail
  },
}))
```

**Correct (proper loading and error states):**

```typescript
interface UserState {
  user: User | null
  isLoading: boolean
  error: Error | null
  fetchUser: (id: string) => Promise<void>
}

const useUserStore = create<UserState>((set) => ({
  user: null,
  isLoading: false,
  error: null,

  fetchUser: async (id: string) => {
    set({ isLoading: true, error: null })

    try {
      const response = await fetch(`/api/users/${id}`)

      if (!response.ok) {
        throw new Error(`Failed to fetch user: ${response.status}`)
      }

      const user = await response.json()
      set({ user, isLoading: false })
    } catch (error) {
      set({
        error: error instanceof Error ? error : new Error('Unknown error'),
        isLoading: false,
      })
    }
  },
}))

// Usage in component
function UserProfile({ id }: { id: string }) {
  const { user, isLoading, error, fetchUser } = useUserStore()

  useEffect(() => {
    fetchUser(id)
  }, [id, fetchUser])

  if (isLoading) return <Spinner />
  if (error) return <ErrorMessage error={error} />
  if (!user) return null

  return <Profile user={user} />
}
```

**Alternative (abort previous requests):**

```typescript
const useUserStore = create<UserState>((set, get) => ({
  user: null,
  isLoading: false,
  abortController: null as AbortController | null,

  fetchUser: async (id: string) => {
    // Abort any in-flight request
    get().abortController?.abort()

    const abortController = new AbortController()
    set({ isLoading: true, abortController })

    try {
      const response = await fetch(`/api/users/${id}`, {
        signal: abortController.signal,
      })
      const user = await response.json()
      set({ user, isLoading: false })
    } catch (error) {
      if (error.name !== 'AbortError') {
        set({ isLoading: false })
      }
    }
  },
}))
```

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
