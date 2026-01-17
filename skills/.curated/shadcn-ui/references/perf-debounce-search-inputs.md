---
title: Debounce Search and Filter Inputs
impact: MEDIUM
impactDescription: reduces API calls by 80-90% during typing
tags: perf, debounce, search, filtering, api
---

## Debounce Search and Filter Inputs

Debounce search inputs to prevent API calls on every keystroke. Users type 3-5 characters per second; calling the API each time overwhelms the server and UI.

**Incorrect (API call on every keystroke):**

```tsx
function SearchUsers() {
  const [query, setQuery] = useState("")
  const { data, isLoading } = useQuery(
    ["users", query],
    () => searchUsers(query),
    { enabled: query.length > 0 }
  )
  // User types "john" = 4 API calls in < 1 second

  return (
    <div className="space-y-4">
      <Input
        placeholder="Search users..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      {isLoading && <Skeleton className="h-20" />}
      {/* Results flicker between each keystroke */}
    </div>
  )
}
```

**Correct (debounced search):**

```tsx
import { useDebouncedValue } from "@/hooks/use-debounced-value"

function SearchUsers() {
  const [query, setQuery] = useState("")
  const debouncedQuery = useDebouncedValue(query, 300) // 300ms delay

  const { data, isLoading } = useQuery(
    ["users", debouncedQuery],
    () => searchUsers(debouncedQuery),
    { enabled: debouncedQuery.length > 0 }
  )
  // User types "john" = 1 API call after they stop typing

  return (
    <div className="space-y-4">
      <Input
        placeholder="Search users..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      {isLoading && <Skeleton className="h-20" />}
      {/* Stable results, no flickering */}
    </div>
  )
}
```

**useDebouncedValue hook:**

```tsx
function useDebouncedValue<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}
```

**Recommended delays:**
- Search inputs: 300-500ms
- Autocomplete: 150-300ms
- Filter updates: 200-400ms
- Form field validation: 500ms

Reference: [use-debounce](https://github.com/xnimorz/use-debounce)
