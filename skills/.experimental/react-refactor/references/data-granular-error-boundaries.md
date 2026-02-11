---
title: Place Error Boundaries at Data Fetch Granularity
impact: MEDIUM
impactDescription: prevents full-page crash from single component failure
tags: data, error-boundaries, resilience, fault-isolation
---

## Place Error Boundaries at Data Fetch Granularity

A single error boundary at the application root kills the entire page when any component throws. If one API call fails, the user loses access to every feature on screen. Placing error boundaries around each independent data-fetching section isolates failures so the rest of the page stays functional.

**Incorrect (single root boundary — one failure kills everything):**

```tsx
import { ErrorBoundary } from "react-error-boundary";

export default function DashboardPage() {
  return (
    <ErrorBoundary fallback={<FullPageError />}>
      <Suspense fallback={<PageSkeleton />}>
        <DashboardHeader />
        <RevenueChart />     {/* if this throws... */}
        <RecentOrders />     {/* ...user loses this too */}
        <TeamActivity />     {/* ...and this */}
        <SystemAlerts />     {/* ...and this */}
      </Suspense>
    </ErrorBoundary>
  );
}

// Any single failure replaces the entire dashboard with FullPageError
```

**Correct (per-section boundaries — failures stay contained):**

```tsx
import { ErrorBoundary } from "react-error-boundary";

function SectionError({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert" className="section-error">
      <p>Failed to load: {error.message}</p>
      <button onClick={resetErrorBoundary}>Retry</button>
    </div>
  );
}

export default function DashboardPage() {
  return (
    <>
      <DashboardHeader />
      <ErrorBoundary FallbackComponent={SectionError}>
        <Suspense fallback={<ChartSkeleton />}>
          <RevenueChart />
        </Suspense>
      </ErrorBoundary>
      <ErrorBoundary FallbackComponent={SectionError}>
        <Suspense fallback={<TableSkeleton />}>
          <RecentOrders />
        </Suspense>
      </ErrorBoundary>
      <ErrorBoundary FallbackComponent={SectionError}>
        <Suspense fallback={<FeedSkeleton />}>
          <TeamActivity />
        </Suspense>
      </ErrorBoundary>
      <ErrorBoundary FallbackComponent={SectionError}>
        <Suspense fallback={<AlertsSkeleton />}>
          <SystemAlerts />
        </Suspense>
      </ErrorBoundary>
    </>
  );
}
// RevenueChart failure shows retry button; RecentOrders, TeamActivity, SystemAlerts remain usable
```

Reference: [React Docs - Catching rendering errors with an error boundary](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
