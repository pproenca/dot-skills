---
title: Contain each async failure to its own subtree via `error.tsx` or `ErrorBoundary` — one bad fetch must not take down the route
impact: MEDIUM
impactDescription: isolates Server Component failures to their region; prevents one failed API call from rendering an empty page
tags: server, error-isolation, error-tsx, error-boundary
---

## Contain each async failure to its own subtree via `error.tsx` or `ErrorBoundary` — one bad fetch must not take down the route

**Pattern intent:** every async leaf can fail (network, timeout, upstream 500). The fix is to scope failures to the smallest subtree that can be displayed without the failed data, not to let them unwind to the route boundary.

### Shapes to recognize

- A `page.tsx` with multiple `await fetch(...)` calls and no `error.tsx` next to it — any failure renders the framework's default error.
- A page with `error.tsx` but no per-subtree `<ErrorBoundary>` — a failed analytics widget takes down the whole dashboard.
- A `try/catch` around each fetch returning a fallback JSX — works but conflates loading vs error vs success and loses the per-subtree retry.
- A `return null` on caught error — failure becomes invisible; no retry, no logging.
- An `error.tsx` at the route root that doesn't reset state correctly — the user sees the error, retries, sees the error again because state didn't reset.

The canonical resolution: per-route `error.tsx` for route-level failures; `<ErrorBoundary>` around each `<Suspense>`-wrapped async leaf for granular containment. Both have `reset` semantics. Use `react-error-boundary` for client-component-level isolation when needed.

**Incorrect (unhandled error crashes page):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const analytics = await fetchAnalytics()  // If this fails, entire page crashes

  return (
    <div>
      <Header />
      <Analytics data={analytics} />
    </div>
  )
}
```

**Correct (graceful error handling):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

export default function DashboardPage() {
  return (
    <div>
      <Header />
      <ErrorBoundary fallback={<AnalyticsError />}>
        <Suspense fallback={<AnalyticsSkeleton />}>
          <Analytics />
        </Suspense>
      </ErrorBoundary>
    </div>
  )
}

// Or use error.tsx for route-level errors
// app/dashboard/error.tsx
'use client'

export default function Error({
  error,
  reset
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

**Try/catch for specific components:**

```typescript
async function Analytics() {
  try {
    const data = await fetchAnalytics()
    return <AnalyticsChart data={data} />
  } catch (error) {
    return <AnalyticsUnavailable />
  }
}
```
