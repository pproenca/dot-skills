---
title: Use Parallel Routes for Independent Content
impact: HIGH
impactDescription: independent loading, streaming, error handling
tags: route, parallel-routes, slots, layout
---

## Use Parallel Routes for Independent Content

Parallel routes (slots) render multiple pages simultaneously in the same layout. Each slot can have independent loading, error, and streaming states.

**Incorrect (sequential rendering in single page):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const analytics = await fetchAnalytics()  // Slow
  const notifications = await fetchNotifications()
  const activity = await fetchActivity()

  return (
    <div className="grid grid-cols-3">
      <Analytics data={analytics} />
      <Notifications data={notifications} />
      <Activity data={activity} />
    </div>
  )
}
// All sections wait for slowest fetch
```

**Correct (parallel routes with independent streaming):**

```text
app/dashboard/
├── layout.tsx
├── @analytics/
│   ├── page.tsx
│   └── loading.tsx
├── @notifications/
│   ├── page.tsx
│   └── loading.tsx
└── @activity/
    ├── page.tsx
    └── loading.tsx
```

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  analytics,
  notifications,
  activity
}: {
  analytics: React.ReactNode
  notifications: React.ReactNode
  activity: React.ReactNode
}) {
  return (
    <div className="grid grid-cols-3">
      {analytics}
      {notifications}
      {activity}
    </div>
  )
}

// app/dashboard/@analytics/page.tsx
export default async function AnalyticsSlot() {
  const data = await fetchAnalytics()
  return <Analytics data={data} />
}
// Each slot streams independently
```

**Benefits:**
- Each slot loads independently
- Each slot has its own loading.tsx
- Each slot can have its own error.tsx
