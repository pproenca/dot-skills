---
title: Separate Utility Hooks from Domain Hooks
impact: MEDIUM-HIGH
impactDescription: improves reusability 5×, clarifies hook responsibilities
tags: abs, hooks, utility, domain, separation-of-concerns
---

## Separate Utility Hooks from Domain Hooks

Mixing generic utilities with domain logic in hooks creates tight coupling. Keep utility hooks generic and domain hooks specific.

**Code Smell Indicators:**
- Hook named `useUserData` contains debounce logic
- Generic hook has business-specific defaults
- Can't reuse hook because of embedded domain logic
- Hook does "one thing" that's actually three things

**Incorrect (utility mixed with domain):**

```tsx
// This hook mixes: debouncing (utility), fetching (utility), and user logic (domain)
function useUserSearch(initialQuery = '') {
  const [query, setQuery] = useState(initialQuery)
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    // Debounce logic (utility)
    const timer = setTimeout(() => {
      if (query.length < 2) return // Domain rule: min 2 chars

      setLoading(true)
      // User-specific fetch (domain)
      fetch(`/api/users?q=${query}&role=active`) // Domain: only active users
        .then(r => r.json())
        .then(data => {
          // Domain-specific transformation
          setUsers(data.map(u => ({
            ...u,
            displayName: `${u.firstName} ${u.lastName}`,
          })))
        })
        .finally(() => setLoading(false))
    }, 300) // Hardcoded debounce (utility mixed with domain)

    return () => clearTimeout(timer)
  }, [query])

  return { query, setQuery, users, loading }
}

// Can't reuse for product search because user logic is embedded
```

**Correct (separated concerns):**

```tsx
// Utility hook: generic debounce
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}

// Utility hook: generic async data
function useAsync<T>(asyncFn: () => Promise<T>, deps: unknown[]) {
  const [state, setState] = useState<{
    status: 'idle' | 'loading' | 'success' | 'error'
    data: T | null
    error: Error | null
  }>({ status: 'idle', data: null, error: null })

  useEffect(() => {
    setState({ status: 'loading', data: null, error: null })
    asyncFn()
      .then(data => setState({ status: 'success', data, error: null }))
      .catch(error => setState({ status: 'error', data: null, error }))
  }, deps)

  return state
}

// Domain hook: user-specific logic, composes utilities
function useUserSearch() {
  const [query, setQuery] = useState('')
  const debouncedQuery = useDebounce(query, 300)

  const { data: users, status } = useAsync(
    async () => {
      if (debouncedQuery.length < 2) return []

      const response = await fetch(`/api/users?q=${debouncedQuery}&role=active`)
      const data = await response.json()

      // Domain-specific transformation
      return data.map(u => ({
        ...u,
        displayName: `${u.firstName} ${u.lastName}`,
      }))
    },
    [debouncedQuery]
  )

  return { query, setQuery, users: users ?? [], loading: status === 'loading' }
}

// Now we can reuse utilities for other domains
function useProductSearch() {
  const [query, setQuery] = useState('')
  const debouncedQuery = useDebounce(query, 500) // Different debounce

  const { data: products, status } = useAsync(
    async () => {
      if (debouncedQuery.length < 1) return [] // Different min length
      return fetchProducts(debouncedQuery)
    },
    [debouncedQuery]
  )

  return { query, setQuery, products: products ?? [], loading: status === 'loading' }
}
```

**Separation criteria:**

| Utility Hooks | Domain Hooks |
|---------------|--------------|
| Generic, no business logic | Business-specific logic |
| Reusable across domains | Specific to one feature |
| No API endpoints | Calls specific APIs |
| Examples: useDebounce, useAsync, useLocalStorage | Examples: useUserSearch, useCartTotal |

**Composition pattern:**
```
Domain Hook
├── Utility Hook (debounce)
├── Utility Hook (async)
└── Domain Logic (transformation, validation, API specifics)
```

Reference: [Custom Hooks Best Practices](https://react.dev/learn/reusing-logic-with-custom-hooks#custom-hooks-let-you-share-stateful-logic-not-state-itself)
