---
title: Use Layouts for Shared Data and UI
impact: HIGH
impactDescription: Layouts don't re-render on navigation; fetched data persists across route changes, eliminating redundant requests
tags: server, layouts, navigation, persistence
---

## Use Layouts for Shared Data and UI

Layouts persist across route changes within their segment. Data fetched in a layout doesn't re-fetch when navigating between child pages. Use this for shared UI (nav, sidebar) and data (user session, preferences).

**Incorrect (fetching in every page):**

```typescript
// app/dashboard/analytics/page.tsx
export default async function AnalyticsPage() {
  const user = await getUser()  // Fetches on every navigation
  return (
    <div>
      <Sidebar user={user} />
      <Analytics />
    </div>
  )
}

// app/dashboard/settings/page.tsx
export default async function SettingsPage() {
  const user = await getUser()  // Same fetch, different page
  return (
    <div>
      <Sidebar user={user} />
      <Settings />
    </div>
  )
}
// Navigating between pages re-fetches user each time
```

**Correct (shared layout):**

```typescript
// app/dashboard/layout.tsx
export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const user = await getUser()  // Fetched once, persists during navigation

  return (
    <div className="flex">
      <Sidebar user={user} />
      <main>{children}</main>
    </div>
  )
}

// app/dashboard/analytics/page.tsx
export default async function AnalyticsPage() {
  return <Analytics />  // No user fetch needed
}

// app/dashboard/settings/page.tsx
export default async function SettingsPage() {
  return <Settings />  // No user fetch needed
}
// Navigating between pages keeps layout and its data
```

**Nested layouts for hierarchical data:**

```typescript
// app/shop/layout.tsx - Shop-level data
export default async function ShopLayout({ children }) {
  const categories = await getCategories()
  return (
    <div>
      <CategoryNav categories={categories} />
      {children}
    </div>
  )
}

// app/shop/[category]/layout.tsx - Category-level data
export default async function CategoryLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: Promise<{ category: string }>
}) {
  const { category } = await params
  const filters = await getCategoryFilters(category)
  return (
    <div>
      <FilterSidebar filters={filters} />
      {children}
    </div>
  )
}
```

**Layout persistence rules:**
- Layouts don't re-render when navigating to child routes
- Layouts DO re-render when their segment changes
- State in Client Components within layouts persists

**When NOT to use layouts:**
- Data that should refresh on every navigation
- Page-specific UI that changes per route
- Data dependent on page params (use page component)

Reference: [Next.js Layouts](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates)
