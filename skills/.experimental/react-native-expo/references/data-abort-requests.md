---
title: Abort Requests on Component Unmount
impact: HIGH
impactDescription: prevents memory leaks and wasted bandwidth
tags: data, abort, cleanup, useEffect, AbortController
---

## Abort Requests on Component Unmount

Requests continuing after component unmount waste bandwidth and can cause state update errors.

**Incorrect (request continues after unmount):**

```tsx
function SearchResults({ query }) {
  const [results, setResults] = useState([])

  useEffect(() => {
    fetchResults(query).then(data => {
      // Error if component unmounted before response
      // "Can't perform state update on unmounted component"
      setResults(data)
    })
  }, [query])

  return <ResultsList results={results} />
}
// User types fast, each keystroke triggers fetch
// Previous fetches continue even after new one starts
```

**Correct (abort on cleanup):**

```tsx
function SearchResults({ query }) {
  const [results, setResults] = useState([])

  useEffect(() => {
    const controller = new AbortController()

    async function search() {
      try {
        const data = await fetch(`/api/search?q=${query}`, {
          signal: controller.signal
        }).then(r => r.json())

        setResults(data)
      } catch (error) {
        if (error.name !== 'AbortError') {
          console.error('Search failed:', error)
        }
        // AbortError is expected on cleanup, don't log it
      }
    }

    search()

    return () => {
      controller.abort()  // Cancel on unmount or query change
    }
  }, [query])

  return <ResultsList results={results} />
}
```

**With TanStack Query (automatic cancellation):**

```tsx
function SearchResults({ query }) {
  const { data: results } = useQuery({
    queryKey: ['search', query],
    queryFn: ({ signal }) => {
      // TanStack Query provides signal automatically
      return fetch(`/api/search?q=${query}`, { signal })
        .then(r => r.json())
    },
    // Abort previous request when query changes
    keepPreviousData: true,
  })

  return <ResultsList results={results ?? []} />
}
// Automatic abort on unmount and query change
```

**Debounced search with abort:**

```tsx
function SearchInput() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])

  useEffect(() => {
    if (!query) {
      setResults([])
      return
    }

    const controller = new AbortController()

    // Debounce: wait 300ms after typing stops
    const timeoutId = setTimeout(async () => {
      try {
        const data = await fetch(`/api/search?q=${query}`, {
          signal: controller.signal
        }).then(r => r.json())
        setResults(data)
      } catch (error) {
        if (error.name !== 'AbortError') {
          console.error(error)
        }
      }
    }, 300)

    return () => {
      clearTimeout(timeoutId)  // Clear debounce timer
      controller.abort()        // Abort in-flight request
    }
  }, [query])

  return (
    <>
      <TextInput value={query} onChangeText={setQuery} />
      <ResultsList results={results} />
    </>
  )
}
```

**Abort multiple parallel requests:**

```tsx
useEffect(() => {
  const controller = new AbortController()

  Promise.all([
    fetch('/api/user', { signal: controller.signal }),
    fetch('/api/posts', { signal: controller.signal }),
  ]).then(/* ... */)

  return () => controller.abort()  // Aborts all requests
}, [])
```

Reference: [AbortController MDN](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
