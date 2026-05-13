---
title: Independent server fetches run concurrently — sequential `await` is a server-side waterfall
impact: HIGH
impactDescription: collapses N sequential server-side awaits to max(latencies); 2-5x speedup on multi-fetch pages and dashboards
tags: server, parallel-fetch, waterfall, concurrent-await
---

## Independent server fetches run concurrently — sequential `await` is a server-side waterfall

**Pattern intent:** when a Server Component needs two or more pieces of data that don't depend on each other, they should be in flight simultaneously. The pattern break is "sequential `await` for independent data" — the page's TTFB becomes the sum of latencies instead of the max.

### Shapes to recognize

- Two or more `const x = await fetchX(); const y = await fetchY();` lines at the top of an async Server Component where `y` doesn't reference `x`.
- A `for (const id of ids) { items.push(await fetchOne(id)) }` loop — each iteration blocks the next.
- Three `await db.foo.findFirst(...)` calls in a row at the top of a `page.tsx` where the third doesn't depend on the first two.
- A layout that awaits one fetch, then renders a Server Component child that awaits another — the layout's render is in the critical path; if neither fetch depends on the other, both should fire in parallel.
- Workaround: a `useEffect` in a client component that orchestrates two `fetch` calls in parallel because the server version was "too hard" — defeats the SSR benefit.

The canonical resolution: `const [a, b, c] = await Promise.all([fetchA(), fetchB(), fetchC()])` for hard dependencies; `Promise.allSettled` when each branch should tolerate others' failures. When *some* fetches depend on a result (the user ID), serialize only the dependency boundary, then parallelize the rest.

**Incorrect (sequential fetches, 3 round trips):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 150ms
  const notifications = await fetchNotifications()  // 100ms
  // Total: 450ms (sequential)

  return (
    <Dashboard
      user={user}
      orders={orders}
      notifications={notifications}
    />
  )
}
```

**Correct (parallel fetches, 1 round trip):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const [user, orders, notifications] = await Promise.all([
    fetchUser(),           // 200ms
    fetchOrders(),         // 150ms (parallel)
    fetchNotifications()   // 100ms (parallel)
  ])
  // Total: 200ms (longest request)

  return (
    <Dashboard
      user={user}
      orders={orders}
      notifications={notifications}
    />
  )
}
```

**With dependent data:**

```typescript
export default async function DashboardPage() {
  // First fetch user (needed for subsequent queries)
  const user = await fetchUser()

  // Then fetch user-dependent data in parallel
  const [orders, preferences] = await Promise.all([
    fetchOrders(user.id),
    fetchPreferences(user.id)
  ])

  return <Dashboard user={user} orders={orders} preferences={preferences} />
}
```

---

### In disguise — sequential fetches hidden across parent/child Server Components

The grep-friendly anti-pattern is N `await` statements in one function. The disguise is the *same* sequential pattern split across a parent and a child Server Component — the parent awaits A and renders the child; the child awaits B. The waterfall is invisible at the file level but causes the same TTFB regression.

**Incorrect — in disguise (parent awaits A, child awaits B, no overlap):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await fetchUser()        // 200ms — parent blocks
  return (
    <Dashboard>
      <UserHeader user={user} />
      <OrdersSection />                  // child fetches independently
    </Dashboard>
  )
}

// app/dashboard/OrdersSection.tsx
export async function OrdersSection() {
  const orders = await fetchOrders()    // 150ms — runs after user fetch lands
  return <OrderList orders={orders} />
}
// Total: 350ms (sequential), even though orders doesn't depend on user
```

The page-level `Promise.all` is missing because the two fetches don't live in the same file. The audit needs to see the *route* as a whole, not just the page.

**Correct — preload pattern triggers both in parallel:**

```typescript
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async () => fetchUser())
export const getOrders = cache(async () => fetchOrders())

export const preloadOrders = () => { void getOrders() } // fire-and-forget

// app/dashboard/page.tsx
import { getUser, preloadOrders } from '@/lib/data'

export default async function DashboardPage() {
  preloadOrders()           // start orders fetch immediately, don't await
  const user = await getUser()  // 200ms — both fetches run in parallel
  return (
    <Dashboard>
      <UserHeader user={user} />
      <OrdersSection />
    </Dashboard>
  )
}

// app/dashboard/OrdersSection.tsx — no change
export async function OrdersSection() {
  const orders = await getOrders()  // cached promise, resolves at 150ms mark
  return <OrderList orders={orders} />
}
// Total: 200ms (max of the two)
```

The `preload` pattern bridges the parent/child boundary so the descendant's fetch starts as early as the parent's. Combine with `<Suspense>` to stream the child as soon as it resolves.
