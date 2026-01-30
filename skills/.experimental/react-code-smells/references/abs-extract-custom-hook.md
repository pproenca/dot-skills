---
title: Extract Custom Hooks for Reusable Logic
impact: HIGH
impactDescription: enables logic reuse across components, improves testability by 3×
tags: abs, custom-hooks, extraction, reuse, testability
---

## Extract Custom Hooks for Reusable Logic

Logic that combines multiple hooks or manages complex state should be extracted to custom hooks for reuse and testability.

**Code Smell Indicators:**
- Same useState + useEffect pattern in multiple components
- Complex logic interleaved with JSX
- Hard to test component behavior
- "This component does too much"

**Incorrect (logic mixed with rendering):**

```tsx
function ProductSearch() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [page, setPage] = useState(1)
  const [hasMore, setHasMore] = useState(true)

  // Debounced search
  useEffect(() => {
    const timer = setTimeout(() => {
      if (query.length < 2) {
        setResults([])
        return
      }
      setLoading(true)
      setError(null)
      searchProducts(query, page)
        .then(data => {
          setResults(prev => page === 1 ? data.items : [...prev, ...data.items])
          setHasMore(data.hasMore)
        })
        .catch(setError)
        .finally(() => setLoading(false))
    }, 300)
    return () => clearTimeout(timer)
  }, [query, page])

  // Reset on new query
  useEffect(() => {
    setPage(1)
    setResults([])
  }, [query])

  // 50 more lines of JSX mixed with this logic
  return (
    <div>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      {/* ... rendering logic */}
    </div>
  )
}
```

**Correct (logic extracted to custom hook):**

```tsx
// Custom hook - testable in isolation
function useSearch<T>(
  searchFn: (query: string, page: number) => Promise<{ items: T[]; hasMore: boolean }>,
  { debounceMs = 300, minLength = 2 } = {}
) {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<T[]>([])
  const [status, setStatus] = useState<'idle' | 'loading' | 'error'>('idle')
  const [error, setError] = useState<Error | null>(null)
  const [page, setPage] = useState(1)
  const [hasMore, setHasMore] = useState(true)

  // Debounced search effect
  useEffect(() => {
    if (query.length < minLength) {
      setResults([])
      setStatus('idle')
      return
    }

    const controller = new AbortController()
    const timer = setTimeout(async () => {
      setStatus('loading')
      try {
        const data = await searchFn(query, page)
        if (!controller.signal.aborted) {
          setResults(prev => page === 1 ? data.items : [...prev, ...data.items])
          setHasMore(data.hasMore)
          setStatus('idle')
        }
      } catch (e) {
        if (!controller.signal.aborted) {
          setError(e as Error)
          setStatus('error')
        }
      }
    }, debounceMs)

    return () => {
      clearTimeout(timer)
      controller.abort()
    }
  }, [query, page, searchFn, debounceMs, minLength])

  // Reset pagination on query change
  useEffect(() => {
    setPage(1)
  }, [query])

  const loadMore = () => {
    if (hasMore && status !== 'loading') {
      setPage(p => p + 1)
    }
  }

  return {
    query, setQuery,
    results, status, error,
    hasMore, loadMore,
  }
}

// Component is now simple and focused on rendering
function ProductSearch() {
  const search = useSearch(searchProducts)

  return (
    <div>
      <input
        value={search.query}
        onChange={e => search.setQuery(e.target.value)}
        placeholder="Search products..."
      />
      {search.status === 'loading' && <Spinner />}
      {search.status === 'error' && <Error error={search.error} />}
      <ProductList products={search.results} />
      {search.hasMore && (
        <button onClick={search.loadMore}>Load More</button>
      )}
    </div>
  )
}
```

**Testing the hook independently:**

```tsx
import { renderHook, act } from '@testing-library/react'

test('useSearch debounces queries', async () => {
  const mockSearch = jest.fn().mockResolvedValue({ items: [], hasMore: false })
  const { result } = renderHook(() => useSearch(mockSearch, { debounceMs: 100 }))

  act(() => result.current.setQuery('test'))
  expect(mockSearch).not.toHaveBeenCalled()

  await act(async () => {
    await new Promise(r => setTimeout(r, 150))
  })
  expect(mockSearch).toHaveBeenCalledWith('test', 1)
})
```

**Extraction heuristics:**
- 3+ useState/useEffect calls → Consider extraction
- Logic reused in 2+ components → Extract
- Want to test behavior without rendering → Extract
- Component file > 150 lines → Look for extraction opportunities

Reference: [Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
