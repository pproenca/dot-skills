---
title: Multi-region layouts that show independent content per region should use parallel-route slots, not one mega `page.tsx`
impact: HIGH
impactDescription: each region gets its own loading/error/streaming lifecycle; one slow region doesn't block the whole layout
tags: route, parallel-routes, slot, independent-streaming
---

## Multi-region layouts that show independent content per region should use parallel-route slots, not one mega `page.tsx`

**Pattern intent:** dashboards, multi-panel layouts, and apps with distinct regions (notifications | feed | sidebar | activity) benefit from rendering each region as a separate route slot (`@analytics/`, `@notifications/`). Each slot has its own `loading.tsx`, `error.tsx`, and streams independently.

### Shapes to recognize

- A single `page.tsx` for a multi-region layout that awaits N data sources before returning — one slow source blocks all regions.
- A page that does `Promise.all([...])` of N independent fetches then renders N components — fine for fast data, but blocks streaming.
- A layout with `<Header/>`, `<Sidebar/>`, `<Main/>`, `<Activity/>` all rendered directly — each region's loading and error states get tangled.
- A "dashboard tile grid" rendered as a flat list of Server Components where each tile is async — works but the layout file has to know which tiles exist.
- Custom "tile loader" abstraction with React Context to coordinate per-tile loading — reinvents parallel routes.

The canonical resolution: create `app/<route>/@slotName/` directories with each region's `page.tsx`/`loading.tsx`/`error.tsx`. The layout accepts each slot as a named prop (`{ analytics, notifications, activity }`). Per-region streaming is automatic.

Reference: [Parallel Routes](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes)

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
