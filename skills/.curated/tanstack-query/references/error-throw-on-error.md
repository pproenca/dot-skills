---
title: Use throwOnError with Error Boundaries
impact: MEDIUM
impactDescription: bubbles errors to boundaries, enables catch-all handling
tags: error, throwOnError, error-boundary, propagation
---

## Use throwOnError with Error Boundaries

By default, query errors are returned in the `error` field. Use `throwOnError: true` to throw errors, which Error Boundaries can catch for consistent error UI.

**Default behavior (errors in state):**

```typescript
function UserProfile() {
  const { data, isError, error } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })

  // Must handle error manually in this component
  if (isError) return <ErrorDisplay error={error} />
  return <div>{data.name}</div>
}
```

**With throwOnError (bubbles to boundary):**

```typescript
function UserProfile() {
  const { data } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
    throwOnError: true, // Throws on error
  })

  // No error handling needed here - boundary catches it
  return <div>{data.name}</div>
}

// Parent handles all errors
function UserPage() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <UserProfile />
    </ErrorBoundary>
  )
}
```

**Conditional throwOnError:**

```typescript
useQuery({
  queryKey: ['user'],
  queryFn: fetchUser,
  // Only throw for server errors, handle 4xx locally
  throwOnError: (error) => error instanceof ApiError && error.status >= 500,
})
```

**Combining with Suspense:**

```typescript
// useSuspenseQuery always throws errors (no throwOnError option)
function UserProfile() {
  const { data } = useSuspenseQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })
  return <div>{data.name}</div>
}

// Must have both Suspense AND Error Boundary
function UserPage() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**Global throwOnError:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      throwOnError: (error) => error instanceof ApiError && error.status >= 500,
    },
  },
})
```
