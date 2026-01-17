---
title: Use Global Error Handler for Common Errors
impact: MEDIUM
impactDescription: centralizes error handling, consistent UX
tags: error, global, handler, toast, redirect
---

## Use Global Error Handler for Common Errors

Handling authentication errors, network failures, and server errors in every component creates duplication. Use QueryClient's global error handler for common patterns.

**Incorrect (duplicated in every query):**

```typescript
function UserProfile() {
  const { data, error } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })

  useEffect(() => {
    if (error?.status === 401) {
      router.push('/login')
    }
    if (error?.status >= 500) {
      toast.error('Server error, please try again')
    }
  }, [error])
}

// Repeated in every component that uses queries...
```

**Correct (global handler):**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: (failureCount, error) => {
        // Don't retry auth errors
        if (error instanceof ApiError && error.status === 401) {
          return false
        }
        return failureCount < 2
      },
    },
  },
  queryCache: new QueryCache({
    onError: (error, query) => {
      if (error instanceof ApiError) {
        // Redirect on auth errors
        if (error.status === 401) {
          window.location.href = '/login'
          return
        }

        // Toast for server errors (but only for user-facing queries)
        if (error.status >= 500 && !query.meta?.silent) {
          toast.error('Something went wrong. Please try again.')
        }
      }
    },
  }),
  mutationCache: new MutationCache({
    onError: (error, variables, context, mutation) => {
      if (error instanceof ApiError && error.status >= 500) {
        toast.error('Failed to save. Please try again.')
      }
    },
  }),
})
```

**Using query meta for control:**

```typescript
// Silent query - don't show global toast
useQuery({
  queryKey: ['background-sync'],
  queryFn: syncData,
  meta: { silent: true },
})

// User-facing query - show global toast on error
useQuery({
  queryKey: ['user'],
  queryFn: fetchUser,
  // No meta.silent - global handler will toast on error
})
```
