---
title: Handle Server Component Errors Gracefully
impact: MEDIUM
impactDescription: prevents full page crashes, better UX
tags: server, error-handling, error-boundary, resilience
---

## Handle Server Component Errors Gracefully

Use error boundaries and try/catch to handle failures gracefully. A single failed fetch shouldn't crash the entire page.

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
