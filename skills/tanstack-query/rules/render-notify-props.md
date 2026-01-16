---
title: Use notifyOnChangeProps to Limit Re-renders
impact: LOW-MEDIUM
impactDescription: prevents re-renders for unused state changes
tags: render, notifyOnChangeProps, optimization, re-renders
---

## Use notifyOnChangeProps to Limit Re-renders

Components re-render when any query state changes (data, error, isLoading, isFetching, etc.). Use `notifyOnChangeProps` to subscribe only to specific properties.

**Default behavior (re-renders on any change):**

```typescript
function DataDisplay() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  // Re-renders when:
  // - data changes ✓ (we use this)
  // - error changes ✗ (we don't use this)
  // - isFetching changes ✗ (we don't use this)
  // - isStale changes ✗ (we don't use this)

  return <div>{data?.value}</div>
}
```

**Optimized (only re-render for data changes):**

```typescript
function DataDisplay() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
    notifyOnChangeProps: ['data'], // Only re-render when data changes
  })

  return <div>{data?.value}</div>
}
```

**Common patterns:**

```typescript
// Only care about data and error
notifyOnChangeProps: ['data', 'error'],

// Show loading state
notifyOnChangeProps: ['data', 'isPending'],

// Track background fetching
notifyOnChangeProps: ['data', 'isFetching'],
```

**Prefetch without re-renders:**

```typescript
function Article({ id }: { id: string }) {
  // Main query - normal behavior
  const { data } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  // Prefetch comments - don't re-render this component at all
  useQuery({
    queryKey: ['comments', id],
    queryFn: () => fetchComments(id),
    notifyOnChangeProps: [], // Never causes re-render
  })

  return <ArticleContent article={data} />
}
```

**Auto-detection with tracked queries:**

```typescript
// TanStack Query can auto-track which props you access
// Enable via QueryClient config:
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      notifyOnChangeProps: 'all', // Or specific props
    },
  },
})
```
