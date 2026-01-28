---
title: Implement Efficient Pagination for Large Datasets
impact: MEDIUM-HIGH
impactDescription: prevents loading 1000+ items at once
tags: data, pagination, infinite-scroll, flatlist, performance
---

## Implement Efficient Pagination for Large Datasets

Loading all data at once causes memory issues and slow initial load. Use pagination to load data incrementally.

**Incorrect (load all data at once):**

```tsx
function ProductList() {
  const [products, setProducts] = useState([])

  useEffect(() => {
    // Fetches all 10,000 products at once
    fetchAllProducts().then(setProducts)
  }, [])

  return (
    <FlatList
      data={products}
      renderItem={renderProduct}
    />
  )
}
// Huge initial payload, memory pressure, slow render
```

**Correct (paginated loading):**

```tsx
function ProductList() {
  const [products, setProducts] = useState([])
  const [page, setPage] = useState(1)
  const [hasMore, setHasMore] = useState(true)
  const [isLoading, setIsLoading] = useState(false)

  const loadMore = useCallback(async () => {
    if (isLoading || !hasMore) return

    setIsLoading(true)
    try {
      const newProducts = await fetchProducts({ page, limit: 20 })
      setProducts(prev => [...prev, ...newProducts])
      setHasMore(newProducts.length === 20)
      setPage(prev => prev + 1)
    } finally {
      setIsLoading(false)
    }
  }, [page, isLoading, hasMore])

  useEffect(() => {
    loadMore()
  }, [])

  return (
    <FlatList
      data={products}
      renderItem={renderProduct}
      onEndReached={loadMore}
      onEndReachedThreshold={0.5}
      ListFooterComponent={isLoading ? <Spinner /> : null}
    />
  )
}
```

**With TanStack Query infinite queries:**

```tsx
import { useInfiniteQuery } from '@tanstack/react-query'

function ProductList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['products'],
    queryFn: ({ pageParam = 1 }) =>
      fetchProducts({ page: pageParam, limit: 20 }),
    getNextPageParam: (lastPage, pages) =>
      lastPage.length === 20 ? pages.length + 1 : undefined,
  })

  const products = data?.pages.flat() ?? []

  return (
    <FlatList
      data={products}
      renderItem={renderProduct}
      onEndReached={() => {
        if (hasNextPage && !isFetchingNextPage) {
          fetchNextPage()
        }
      }}
      onEndReachedThreshold={0.5}
      ListFooterComponent={isFetchingNextPage ? <Spinner /> : null}
    />
  )
}
```

**Cursor-based pagination (more efficient):**

```tsx
const {
  data,
  fetchNextPage,
  hasNextPage,
} = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) =>
    fetchPosts({ cursor: pageParam, limit: 20 }),
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  // Cursor-based avoids issues with items added/removed
})
```

**Prevent duplicate onEndReached calls:**

```tsx
const isLoadingRef = useRef(false)

const handleEndReached = useCallback(() => {
  if (isLoadingRef.current || !hasNextPage) return

  isLoadingRef.current = true
  fetchNextPage().finally(() => {
    isLoadingRef.current = false
  })
}, [hasNextPage, fetchNextPage])

<FlatList
  onEndReached={handleEndReached}
  onEndReachedThreshold={0.5}
/>
```

**Benefits:**
- Fast initial load
- Lower memory usage
- Better scroll performance
- Works with any dataset size

Reference: [TanStack Query Infinite Queries](https://tanstack.com/query/latest/docs/react/guides/infinite-queries)
