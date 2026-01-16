---
title: Place Suspense Boundaries Strategically
impact: CRITICAL
impactDescription: enables progressive streaming, faster perceived load times
tags: async, suspense, streaming, boundaries, ux
---

## Place Suspense Boundaries Strategically

Suspense boundaries control what loads together. Too few boundaries block the entire page; too many create jarring loading states. Place boundaries around independent content sections.

**Incorrect (single boundary blocks everything):**

```tsx
export default function DashboardPage() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Header />           {/* Fast */}
      <Sidebar />          {/* Fast */}
      <MainContent />      {/* Slow - blocks everything */}
      <RecentActivity />   {/* Medium */}
    </Suspense>
  )
}
// User sees nothing until slowest component resolves
```

**Correct (independent boundaries enable streaming):**

```tsx
export default function DashboardPage() {
  return (
    <>
      <Header />  {/* No data fetching, renders immediately */}

      <div className="layout">
        <Suspense fallback={<SidebarSkeleton />}>
          <Sidebar />
        </Suspense>

        <main>
          <Suspense fallback={<ContentSkeleton />}>
            <MainContent />  {/* Slow component isolated */}
          </Suspense>
        </main>

        <aside>
          <Suspense fallback={<ActivitySkeleton />}>
            <RecentActivity />
          </Suspense>
        </aside>
      </div>
    </>
  )
}
// Each section streams independently as data arrives
```

**Guidelines for boundary placement:**
- Wrap each independent data-fetching section
- Keep related content in the same boundary
- Static content should be outside all boundaries
- Nest boundaries for progressive disclosure

Reference: [Suspense](https://react.dev/reference/react/Suspense)
