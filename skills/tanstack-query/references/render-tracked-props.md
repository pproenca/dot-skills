---
title: Avoid Destructuring All Properties
impact: LOW
impactDescription: prevents subscribing to unused state changes
tags: render, destructuring, optimization, tracked
---

## Avoid Destructuring All Properties

Destructuring query result properties you don't use still subscribes you to their changes. Only destructure what you need, or use `notifyOnChangeProps`.

**Incorrect (subscribed to unused properties):**

```typescript
function SimpleDisplay() {
  // Destructures everything, subscribed to all changes
  const {
    data,
    error,
    isLoading,
    isFetching,
    isError,
    isSuccess,
    status,
    fetchStatus,
    // ... and more
  } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  // But only uses data!
  return <div>{data?.value}</div>
}
```

**Correct (minimal destructuring):**

```typescript
function SimpleDisplay() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  return <div>{data?.value}</div>
}
```

**Access properties only when needed:**

```typescript
function DataWithLoading() {
  const query = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  // Access isPending only in the conditional
  if (query.isPending) return <Skeleton />

  // Access error only if checking for it
  if (query.isError) return <Error message={query.error.message} />

  // Access data for rendering
  return <div>{query.data?.value}</div>
}
```

**Combine with notifyOnChangeProps for explicitness:**

```typescript
function DataOnly() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
    notifyOnChangeProps: ['data'], // Explicit subscription
  })

  return <div>{data?.value}</div>
}
```

**Note:** React Query's tracked queries feature (when enabled) automatically detects which properties you access and optimizes subscriptions. However, explicit `notifyOnChangeProps` is clearer and doesn't rely on runtime detection.
