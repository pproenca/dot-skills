---
title: Combine Streaming with Dynamic Rendering
impact: MEDIUM
impactDescription: reduces perceived load time by 40-60% by showing content progressively
tags: render, streaming, suspense, ux
---

## Combine Streaming with Dynamic Rendering

When dynamic rendering is unavoidable, use Suspense boundaries to stream content progressively. This sends the static shell immediately while dynamic parts load, dramatically improving perceived performance.

**Incorrect (blocking dynamic render):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  // User sees nothing until ALL data loads
  const analytics = await fetchAnalytics()
  const notifications = await fetchNotifications()
  const recommendations = await fetchRecommendations()

  return (
    <div>
      <AnalyticsPanel data={analytics} />
      <NotificationList items={notifications} />
      <RecommendationFeed items={recommendations} />
    </div>
  )
}
```

**Correct (streaming with Suspense):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div>
      {/* Static header sent immediately */}
      <DashboardHeader />

      <Suspense fallback={<AnalyticsSkeleton />}>
        <AnalyticsPanel />
      </Suspense>

      <Suspense fallback={<NotificationSkeleton />}>
        <NotificationList />
      </Suspense>

      <Suspense fallback={<RecommendationSkeleton />}>
        <RecommendationFeed />
      </Suspense>
    </div>
  )
}

// Each component fetches its own data
async function AnalyticsPanel() {
  const analytics = await fetchAnalytics()
  return <AnalyticsView data={analytics} />
}
```

**Benefits of streaming:**

- Static shell (header, navigation) appears instantly
- Each section loads independently as data arrives
- Slow APIs don't block fast ones
- Users can interact with loaded sections immediately

**Use loading.tsx for route-level streaming:**

```typescript
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return <DashboardSkeleton />
}

// Automatically wraps page.tsx in Suspense
```

Reference: [Streaming with Suspense](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
