---
title: Always Pair Suspense with Error Boundaries
impact: HIGH
impactDescription: prevents unhandled exceptions from crashing app
tags: suspense, error-boundary, throwOnError, errors
---

## Always Pair Suspense with Error Boundaries

Suspense queries throw errors as exceptions. Without an Error Boundary, errors crash the app. Always wrap Suspense components with an Error Boundary.

**Incorrect (no error handling):**

```typescript
function App() {
  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userId="123" />
      {/* If query fails, entire app crashes! */}
    </Suspense>
  )
}
```

**Correct (Error Boundary catches errors):**

```typescript
import { ErrorBoundary } from 'react-error-boundary'

function App() {
  return (
    <ErrorBoundary
      fallback={<ErrorDisplay />}
      onReset={() => {
        // Reset any state that caused the error
      }}
    >
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId="123" />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**With retry functionality:**

```typescript
function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  const queryClient = useQueryClient()

  return (
    <div>
      <p>Something went wrong: {error.message}</p>
      <button
        onClick={() => {
          // Clear failed queries before retrying
          queryClient.clear()
          resetErrorBoundary()
        }}
      >
        Try again
      </button>
    </div>
  )
}

function App() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId="123" />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**Granular error boundaries:**

```typescript
function Dashboard() {
  return (
    <div className="grid grid-cols-2 gap-4">
      <ErrorBoundary fallback={<WidgetError />}>
        <Suspense fallback={<WidgetSkeleton />}>
          <RevenueWidget />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<WidgetError />}>
        <Suspense fallback={<WidgetSkeleton />}>
          <UsersWidget />
        </Suspense>
      </ErrorBoundary>
      {/* One widget failing doesn't break the other */}
    </div>
  )
}
```
