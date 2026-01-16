---
title: Use Layouts for Persistent UI
impact: MEDIUM
impactDescription: eliminates re-renders of shared UI on navigation
tags: route, layout, persistence, state, performance
---

## Use Layouts for Persistent UI

Layouts wrap child routes and persist across navigation - they don't re-render or lose state when navigating between sibling routes. Place navigation, sidebars, and other shared UI in layouts to avoid unnecessary re-renders and preserve component state.

**Incorrect (shared UI in page causes re-render on navigation):**

```tsx
// app/dashboard/page.tsx
export default function DashboardPage() {
  return (
    <div>
      <Sidebar />           {/* Re-renders on every navigation */}
      <Navigation />        {/* Re-renders, loses hover/focus state */}
      <DashboardContent />
    </div>
  )
}

// app/settings/page.tsx
export default function SettingsPage() {
  return (
    <div>
      <Sidebar />           {/* Duplicate component, re-mounts */}
      <Navigation />        {/* Loses state from dashboard page */}
      <SettingsContent />
    </div>
  )
}
// Navigation between pages re-renders entire component tree
```

**Correct (layout preserves shared UI):**

```tsx
// app/(app)/layout.tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="app-shell">
      <Sidebar />       {/* Renders once, persists across navigation */}
      <Navigation />    {/* State preserved during route changes */}
      <main>{children}</main>
    </div>
  )
}

// app/(app)/dashboard/page.tsx
export default function DashboardPage() {
  return <DashboardContent />
}

// app/(app)/settings/page.tsx
export default function SettingsPage() {
  return <SettingsContent />
}
// Only page content re-renders; layout components maintain state
```

**With stateful layout components:**

```tsx
// app/(app)/layout.tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="app-shell">
      <CollapsibleSidebar />  {/* Collapse state persists */}
      <main>
        <SearchBar />         {/* Search input value persists */}
        {children}
      </main>
    </div>
  )
}
// User's UI preferences survive navigation
```

**Nested layouts for granular persistence:**

```tsx
// app/(app)/dashboard/layout.tsx
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <DashboardTabs />  {/* Persists only within /dashboard/* routes */}
      {children}
    </>
  )
}
// Tab selection state preserved when navigating between dashboard sub-pages
```

**When NOT to use layouts:**
- UI that should refresh on navigation (notification counts)
- Content that varies based on specific page data
- Components that should re-fetch data on every visit

Reference: [Layouts and Templates](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates)
