---
title: Fetch Data Where Needed Instead of Prop Drilling
impact: HIGH
impactDescription: simplifies component tree, enables parallel fetching, removes 3-5 layers of prop passing
tags: server, data-fetching, architecture, composition
---

## Fetch Data Where Needed Instead of Prop Drilling

With Server Components, fetch data directly in the component that needs it rather than passing props through multiple layers. React's fetch deduplication ensures you won't make redundant requests, and components become self-contained and easier to move around.

**Incorrect (prop drilling through component tree):**

```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await getUser()
  const notifications = await getNotifications(user.id)
  const projects = await getProjects(user.id)

  return (
    <DashboardLayout
      user={user}
      notifications={notifications}
      projects={projects}  // Drilled 3 levels deep
    />
  )
}

// components/dashboard-layout.tsx
function DashboardLayout({ user, notifications, projects }) {
  return (
    <div>
      <Header user={user} notifications={notifications} />
      <Sidebar projects={projects} />  // Just passing through
      <Content projects={projects} />
    </div>
  )
}

// components/sidebar.tsx
function Sidebar({ projects }) {
  return <ProjectList projects={projects} />  // Finally used
}
```

**Correct (fetch where data is used):**

```tsx
// app/dashboard/page.tsx
export default function DashboardPage() {
  return (
    <div className="dashboard">
      <Header />
      <Sidebar />
      <Content />
    </div>
  )
}

// components/header.tsx (Server Component)
export async function Header() {
  const user = await getUser()
  const notifications = await getNotifications(user.id)

  return (
    <header>
      <UserMenu user={user} />
      <NotificationBell notifications={notifications} />
    </header>
  )
}

// components/sidebar.tsx (Server Component)
export async function Sidebar() {
  const user = await getUser()  // Deduped - same request as Header
  const projects = await getProjects(user.id)

  return <ProjectList projects={projects} />
}
// Each component is self-contained and independently testable
```

**Benefits:**
- Components are self-contained and reusable
- Parallel data fetching (Header and Sidebar fetch simultaneously)
- Easier refactoring - move components without rewiring props
- Clearer data dependencies per component

Reference: [Data Fetching Patterns](https://nextjs.org/docs/app/building-your-application/data-fetching/patterns#fetching-data-where-its-needed)
