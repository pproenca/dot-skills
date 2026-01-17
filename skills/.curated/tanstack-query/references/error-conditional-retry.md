---
title: Use Conditional Retry Based on Error Type
impact: HIGH
impactDescription: prevents retrying unrecoverable errors
tags: error, retry, conditional, http-status
---

## Use Conditional Retry Based on Error Type

Retrying 4xx client errors is pointless—the server won't change its mind. Only retry transient errors (network issues, 5xx server errors, rate limits).

**Incorrect (retries everything):**

```typescript
useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  retry: 3, // Retries even 404, 403, 401 errors
})
// User deleted? Retries 3 times before showing "not found"
// Unauthorized? Retries 3 times before redirect to login
```

**Correct (conditional retry):**

```typescript
useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  retry: (failureCount, error) => {
    // Don't retry client errors (4xx)
    if (error instanceof ApiError && error.status >= 400 && error.status < 500) {
      return false
    }
    // Retry server errors up to 3 times
    return failureCount < 3
  },
})
```

**Typed error handling:**

```typescript
class ApiError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string
  ) {
    super(message)
  }

  isRetryable(): boolean {
    // Retry 5xx, 429 (rate limit), network errors
    return (
      this.status >= 500 ||
      this.status === 429 ||
      this.code === 'NETWORK_ERROR'
    )
  }
}

useQuery({
  queryKey: ['data'],
  queryFn: fetchData,
  retry: (failureCount, error) => {
    if (error instanceof ApiError) {
      return error.isRetryable() && failureCount < 3
    }
    // Network errors: retry
    return failureCount < 3
  },
})
```

**Global retry configuration:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: (failureCount, error) => {
        // Never retry 4xx
        if (error instanceof ApiError && error.status >= 400 && error.status < 500) {
          return false
        }
        // Retry others up to 2 times
        return failureCount < 2
      },
    },
  },
})
```
