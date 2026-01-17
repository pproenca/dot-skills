---
title: Use Error Boundaries with Suspense
impact: MEDIUM
impactDescription: graceful error recovery, isolated failures
tags: data, error-boundary, suspense, resilience
---

## Use Error Boundaries with Suspense

Pair Suspense boundaries with Error Boundaries to handle both loading and error states. Failed components don't crash the entire page.

**Incorrect (unhandled errors crash page):**

```typescript
function Dashboard() {
  return (
    <Suspense fallback={<Spinner />}>
      <Analytics />  {/* If this throws, entire page crashes */}
      <Orders />
    </Suspense>
  )
}
```

**Correct (Error Boundary isolates failures):**

```typescript
import { ErrorBoundary } from 'react-error-boundary'

function Dashboard() {
  return (
    <div>
      <ErrorBoundary fallback={<AnalyticsError />}>
        <Suspense fallback={<AnalyticsSkeleton />}>
          <Analytics />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<OrdersError />}>
        <Suspense fallback={<OrdersSkeleton />}>
          <Orders />
        </Suspense>
      </ErrorBoundary>
    </div>
  )
}
// Analytics failure doesn't affect Orders
```

**With retry capability:**

```typescript
function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div className="error-panel">
      <p>Something went wrong: {error.message}</p>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  )
}

function Dashboard() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onReset={() => {
        // Reset any state that might have caused the error
      }}
    >
      <Suspense fallback={<DashboardSkeleton />}>
        <DashboardContent />
      </Suspense>
    </ErrorBoundary>
  )
}
```
