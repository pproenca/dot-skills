---
title: Use Parallel Routes for Complex Layouts
impact: MEDIUM
impactDescription: Independent loading states and error handling per slot; prevents single slow component from blocking entire layout
tags: route, parallel-routes, slots, layouts
---

## Use Parallel Routes for Complex Layouts

Parallel routes (`@folder`) render multiple pages in the same layout simultaneously. Each slot loads independently with its own loading/error states, preventing one slow section from blocking others.

**Incorrect (sequential component rendering):**

```typescript
// Dashboard waits for ALL data before rendering anything
export default async function Dashboard() {
  const [analytics, feed, notifications] = await Promise.all([
    getAnalytics(),     // 500ms
    getFeed(),          // 800ms
    getNotifications(), // 200ms
  ])
  // User sees nothing for 800ms

  return (
    <div className="grid grid-cols-3">
      <AnalyticsPanel data={analytics} />
      <FeedPanel data={feed} />
      <NotificationsPanel data={notifications} />
    </div>
  )
}
```

**Correct (parallel routes with independent loading):**

```
app/
  dashboard/
    @analytics/
      page.tsx
      loading.tsx       # Shows while analytics loads
      error.tsx         # Shows if analytics fails
    @feed/
      page.tsx
      loading.tsx       # Shows while feed loads
    @notifications/
      page.tsx
      loading.tsx       # Shows while notifications load
    layout.tsx          # Composes all slots
    page.tsx            # Optional default content
```

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  analytics,
  feed,
  notifications,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  feed: React.ReactNode
  notifications: React.ReactNode
}) {
  return (
    <div className="grid grid-cols-3">
      {analytics}      {/* Loads independently */}
      {feed}           {/* Loads independently */}
      {notifications}  {/* Loads independently */}
    </div>
  )
}
```

```typescript
// app/dashboard/@analytics/page.tsx
export default async function AnalyticsSlot() {
  const data = await getAnalytics()  // 500ms
  return <AnalyticsPanel data={data} />
}

// app/dashboard/@analytics/loading.tsx
export default function AnalyticsLoading() {
  return <AnalyticsSkeleton />
}
```

**Conditional slots:**

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  analytics,
  modal,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <>
      <main>
        {children}
        {analytics}
      </main>
      {modal}  {/* Conditionally rendered based on URL */}
    </>
  )
}

// app/dashboard/@modal/default.tsx
export default function ModalDefault() {
  return null  // No modal by default
}

// app/dashboard/@modal/settings/page.tsx
export default function SettingsModal() {
  return <Modal><SettingsForm /></Modal>
}
// Navigating to /dashboard/settings shows modal
```

**When NOT to use parallel routes:**
- Simple layouts without independent sections
- Sections that always load together
- When Suspense boundaries are sufficient

Reference: [Next.js Parallel Routes](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes)
