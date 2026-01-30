---
title: Choose Hook Return Type by Use Case
impact: MEDIUM
impactDescription: improves API ergonomics by 40%, enables better destructuring
tags: hook, return-type, tuple, object, api-design
---

## Choose Hook Return Type by Use Case

Hook return types affect usability. Use tuples for positional relationships, objects for optional/many values.

**Code Smell Indicators:**
- Destructuring tuple with many unused positions: `const [, , , setPage] = usePagination()`
- Object destructuring when always using all values
- Renaming every value from object destructuring
- Inconsistent return types across similar hooks

**Incorrect (wrong return type for the use case):**

```tsx
// BAD: Object when tuple would be cleaner (2 tightly coupled values)
function useToggle(initial = false) {
  const [value, setValue] = useState(initial)
  const toggle = useCallback(() => setValue(v => !v), [])

  // Object forces verbose destructuring for simple use case
  return { value, toggle }
}

// Every usage requires object destructuring and can't rename easily
const { value: isOpen, toggle: toggleOpen } = useToggle()
const { value: isEnabled, toggle: toggleEnabled } = useToggle(true)

// BAD: Tuple when object would be cleaner (many optional values)
function usePagination<T>(items: T[], pageSize = 10) {
  const [page, setPage] = useState(1)
  // ... pagination logic

  // Tuple with 7+ values is hard to use
  return [paginatedItems, page, setPage, totalPages, hasNext, hasPrev, nextPage, prevPage]
}

// Consumers must skip unwanted positions
const [items, , , , hasNext, , nextPage] = usePagination(products)
```

**Correct (matching return type to use case):**

```tsx
// GOOD: Tuple for tightly coupled values (2-3 max)
function useToggle(initial = false): [boolean, () => void] {
  const [value, setValue] = useState(initial)
  const toggle = useCallback(() => setValue(v => !v), [])
  return [value, toggle]  // Value and its toggler
}

// Clean usage, easy renaming
const [isOpen, toggleOpen] = useToggle()
const [isEnabled, toggleEnabled] = useToggle(true)

// GOOD: Object for many/optional values
function usePagination<T>(items: T[], pageSize = 10) {
  const [page, setPage] = useState(1)

  const paginatedItems = useMemo(() => {
    const start = (page - 1) * pageSize
    return items.slice(start, start + pageSize)
  }, [items, page, pageSize])

  return {
    items: paginatedItems,
    page,
    setPage,
    totalPages: Math.ceil(items.length / pageSize),
    hasNext: page < Math.ceil(items.length / pageSize),
    hasPrev: page > 1,
    nextPage: () => setPage(p => Math.min(p + 1, Math.ceil(items.length / pageSize))),
    prevPage: () => setPage(p => Math.max(p - 1, 1)),
  }
}

// Pick what you need
const { items, hasNext, nextPage } = usePagination(allProducts)
const { page, totalPages } = usePagination(allProducts)
```

**Decision matrix:**

| Characteristic | Use Tuple | Use Object |
|----------------|-----------|------------|
| Values returned | 2-3 | 4+ |
| All values used together | Yes | Not always |
| Positional relationship | Yes | No |
| Consumers rename values | Often | Rarely |
| Values are optional | No | Yes |

**Hybrid pattern for complex hooks:**

```tsx
// Primary value + helpers object
function useAsync<T>(asyncFn: () => Promise<T>): [
  T | null,
  { loading: boolean; error: Error | null; refetch: () => void }
] {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  // ...
  return [data, { loading, error, refetch }]
}

// Usage: primary value first, details when needed
const [user, { loading, error }] = useAsync(() => fetchUser(id))
const [posts] = useAsync(() => fetchPosts())  // Ignore loading/error
```

Reference: [Custom Hooks API Design](https://react.dev/learn/reusing-logic-with-custom-hooks#naming-your-custom-hooks)
