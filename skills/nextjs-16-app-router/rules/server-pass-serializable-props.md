---
title: Pass Only Serializable Props to Client Components
impact: HIGH
impactDescription: prevents hydration errors and runtime crashes at the RSC boundary
tags: server, client, serialization, props, rsc-boundary
---

## Pass Only Serializable Props to Client Components

Data crossing from Server Components to Client Components must be JSON-serializable. Functions, class instances, Dates, Maps, and Sets cannot be serialized and will cause runtime errors or hydration mismatches that are difficult to debug.

**Incorrect (non-serializable props):**

```tsx
// app/dashboard/page.tsx (Server Component)
import { DashboardClient } from './dashboard-client'

export default async function DashboardPage() {
  const analytics = await getAnalytics()

  return (
    <DashboardClient
      analytics={analytics}
      lastUpdated={analytics.timestamp}  // Date object - not serializable
      onRefresh={() => revalidatePath('/dashboard')}  // Function - cannot cross boundary
      metrics={new Map(analytics.metrics)}  // Map - not serializable
    />
  )
}
```

**Correct (serializable props only):**

```tsx
// app/dashboard/page.tsx (Server Component)
import { DashboardClient } from './dashboard-client'
import { refreshDashboard } from './actions'

export default async function DashboardPage() {
  const analytics = await getAnalytics()

  return (
    <DashboardClient
      analytics={{
        pageViews: analytics.pageViews,
        sessions: analytics.sessions,
        bounceRate: analytics.bounceRate,
      }}
      lastUpdated={analytics.timestamp.toISOString()}  // Serialize to string
      refreshAction={refreshDashboard}  // Server Actions are serializable references
      metrics={Object.fromEntries(analytics.metrics)}  // Convert to plain object
    />
  )
}
```

**Serializable types:**
- Primitives: string, number, bigint, boolean, null, undefined
- Plain objects and arrays containing serializable values
- Server Actions (passed as serialized references)
- Typed arrays (Uint8Array, etc.)

**Not serializable:**
- Functions (except Server Actions)
- Date, Map, Set, WeakMap, WeakSet
- Class instances, Symbols, circular references

Reference: [Passing Props from Server to Client](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#passing-props-from-server-to-client-components-serialization)
