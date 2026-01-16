---
title: Avoid Props Drilling with Server Component Composition
impact: HIGH
impactDescription: Server Components can fetch their own data; eliminates 3-5 levels of prop passing and keeps components self-contained
tags: server, composition, props-drilling, architecture
---

## Avoid Props Drilling with Server Component Composition

Server Components can fetch data directly where needed instead of passing props through multiple layers. This makes components more self-contained and eliminates the "props drilling" anti-pattern.

**Incorrect (props drilling):**

```typescript
// Page fetches everything, passes down
export default async function DashboardPage() {
  const user = await getUser()
  const analytics = await getAnalytics(user.id)
  const notifications = await getNotifications(user.id)
  const recentOrders = await getRecentOrders(user.id)

  return (
    <Dashboard
      user={user}
      analytics={analytics}
      notifications={notifications}
      recentOrders={recentOrders}
    />
  )
}

function Dashboard({ user, analytics, notifications, recentOrders }) {
  return (
    <div>
      <Header user={user} notifications={notifications} />
      <Sidebar user={user} />
      <Main analytics={analytics} recentOrders={recentOrders} />
    </div>
  )
}

function Header({ user, notifications }) {
  return (
    <header>
      <UserMenu user={user} />
      <NotificationBell notifications={notifications} />
    </header>
  )
}
// Props passed through 3 levels...
```

**Correct (composition with direct fetching):**

```typescript
// Page composes independent Server Components
export default function DashboardPage() {
  return (
    <div>
      <Header />
      <Sidebar />
      <Main />
    </div>
  )
}

// Each component fetches its own data
async function Header() {
  return (
    <header>
      <UserMenu />
      <NotificationBell />
    </header>
  )
}

async function UserMenu() {
  const user = await getUser()  // Fetches its own data
  return <div>{user.name}</div>
}

async function NotificationBell() {
  const notifications = await getNotifications()  // Fetches its own data
  return <div>{notifications.unreadCount} unread</div>
}

async function Sidebar() {
  const user = await getUser()  // Cached - same request deduped
  return <nav>{/* user-specific nav */}</nav>
}
```

**Data deduplication:**
Next.js automatically deduplicates fetch requests with the same URL and options during a single render pass. The `getUser()` call in `UserMenu` and `Sidebar` results in only one actual request.

**Pattern with shared data context:**

```typescript
// For truly shared state, use Server Component as data provider
export default async function DashboardLayout({ children }) {
  const user = await getUser()

  return (
    <UserContext value={user}>
      <Header />
      {children}
    </UserContext>
  )
}
```

**When NOT to use this pattern:**
- Data is highly interdependent (fetch together with Promise.all)
- Component tree is shallow (1-2 levels)
- Using React Context for shared client state

Reference: [Next.js Composition Patterns](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns)
