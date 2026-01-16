---
title: Strategic Suspense Boundaries for Progressive Loading
impact: CRITICAL
impactDescription: 50-80% faster perceived load, content streams as it resolves
tags: async, suspense, streaming, progressive, ux
---

## Strategic Suspense Boundaries for Progressive Loading

Suspense boundaries control what content loads together. A single boundary blocks the entire page until the slowest component resolves. Strategic boundaries allow fast content to stream immediately while slow content loads independently.

**Incorrect (single boundary blocks everything):**

```typescript
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Header />              {/* Fast: 50ms */}
      <Sidebar />             {/* Fast: 100ms */}
      <AnalyticsChart />      {/* Slow: 2000ms - blocks entire page */}
      <RecentActivity />      {/* Medium: 300ms */}
    </Suspense>
  )
}
// User sees nothing for 2 seconds
```

**Correct (independent boundaries enable streaming):**

```typescript
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <>
      <Header />  {/* No data fetching, renders immediately */}

      <div className="dashboard-grid">
        <Suspense fallback={<SidebarSkeleton />}>
          <Sidebar />  {/* Streams at 100ms */}
        </Suspense>

        <main>
          <Suspense fallback={<ChartSkeleton />}>
            <AnalyticsChart />  {/* Slow component isolated, streams at 2000ms */}
          </Suspense>
        </main>

        <aside>
          <Suspense fallback={<ActivitySkeleton />}>
            <RecentActivity />  {/* Streams at 300ms */}
          </Suspense>
        </aside>
      </div>
    </>
  )
}
// User sees header instantly, then content progressively
```

**Benefits:**
- Static content renders immediately without waiting
- Each section streams as its data resolves
- Slow components don't block fast components
- Better perceived performance and user experience

**Guidelines for boundary placement:**
- Place static/synchronous content outside all boundaries
- Wrap each independent data-fetching section
- Keep related content that should appear together in the same boundary
- Nest boundaries for progressive disclosure of complex sections

Reference: [Streaming with Suspense](https://nextjs.org/docs/app/getting-started/fetching-data#streaming)
