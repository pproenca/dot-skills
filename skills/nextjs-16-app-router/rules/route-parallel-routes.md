---
title: Use Parallel Routes for Simultaneous Rendering
impact: MEDIUM
impactDescription: 2-5× faster perceived load with independent streaming
tags: route, parallel, slots, layout, streaming
---

## Use Parallel Routes for Simultaneous Rendering

Parallel routes use the `@slot` folder convention to render multiple pages simultaneously in the same layout. Each slot loads independently with its own loading and error states. This is ideal for dashboards, split views, and modal patterns.

**Incorrect (sequential component loading in single page):**

```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const metrics = await fetchMetrics()     // Waits for metrics
  const activity = await fetchActivity()   // Then waits for activity
  const notifications = await fetchNotifications()  // Then waits for notifications

  return (
    <div className="dashboard-grid">
      <MetricsPanel data={metrics} />
      <ActivityFeed data={activity} />
      <NotificationsList data={notifications} />
    </div>
  )
}
// Total time = sum of all fetch times, single loading state for entire page
```

**Correct (parallel routes with independent loading):**

```text
app/dashboard/
├── layout.tsx
├── page.tsx
├── @metrics/
│   ├── page.tsx
│   └── loading.tsx              # Independent skeleton
├── @activity/
│   ├── page.tsx
│   └── loading.tsx
└── @notifications/
    ├── page.tsx
    └── loading.tsx
```

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  metrics,
  activity,
  notifications,
}: {
  children: React.ReactNode
  metrics: React.ReactNode
  activity: React.ReactNode
  notifications: React.ReactNode
}) {
  return (
    <div className="dashboard-grid">
      {metrics}        {/* Streams independently */}
      {activity}       {/* Streams independently */}
      {notifications}  {/* Streams independently */}
      {children}
    </div>
  )
}
// Each slot renders as soon as its data arrives
```

```tsx
// app/dashboard/@metrics/page.tsx
export default async function MetricsSlot() {
  const metrics = await fetchMetrics()
  return <MetricsPanel data={metrics} />
}
// Isolated fetching - doesn't block other slots
```

**With conditional slot rendering:**

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  modal,
}: {
  children: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <>
      {children}
      {modal}  {/* Rendered alongside children when route matches */}
    </>
  )
}
// Modal slot renders when navigating to /dashboard/settings as intercepted route
```

**When to use parallel routes:**
- Dashboard panels that load different data
- Split-screen or multi-pane layouts
- Modal overlays that preserve background content
- Conditional content based on authentication state

Reference: [Parallel Routes](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes)
