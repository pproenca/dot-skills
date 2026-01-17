---
title: Place Suspense Boundaries Strategically
impact: MEDIUM
impactDescription: faster perceived performance, progressive loading
tags: stream, suspense, loading, progressive
---

## Place Suspense Boundaries Strategically

Wrap slow components in Suspense to show meaningful content immediately. Place boundaries around content that fetches data independently.

**Incorrect (single Suspense for entire page):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Suspense fallback={<FullPageLoader />}>
      <Dashboard />
    </Suspense>
  )
}
// User sees full-page spinner until everything loads
```

**Correct (granular Suspense boundaries):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* Fast content renders immediately */}
      <Header />

      {/* Each section loads independently */}
      <Suspense fallback={<StatsSkeleton />}>
        <StatsWidget />
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <RecentOrders />
      </Suspense>
    </div>
  )
}
// Header shows instantly, widgets stream in as they load
```

**Guidelines for Suspense boundaries:**
- Wrap each independent data-fetching component
- Group related components in single boundary
- Keep fallbacks similar in size to actual content (prevent layout shift)
- Prioritize above-the-fold content
