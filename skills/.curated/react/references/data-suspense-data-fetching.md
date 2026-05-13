---
title: Loading states are declared as Suspense fallbacks, not assembled from `if (loading) return …`
impact: HIGH
impactDescription: eliminates manual `useState(loading)` + early-return boilerplate; lets independent subtrees stream their own skeletons
tags: data, suspense, declarative-loading, no-loading-state
---

## Loading states are declared as Suspense fallbacks, not assembled from `if (loading) return …`

**Pattern intent:** "I'm waiting for data" is a structural concern of the component tree, not a control flow concern inside each component. Suspense expresses it structurally — the fallback is JSX, the loading branching is invisible to the consumer.

### Shapes to recognize

- A component with `const [loading, setLoading] = useState(true)` plus `if (loading) return <Skeleton/>` early-return.
- A page-level "isLoading" state derived from N child loading states — one big spinner gating all content.
- A custom hook returning `{ data, isLoading, error }` that callers branch on manually — reinventing Suspense's affordance.
- A `useEffect` that calls multiple fetchers and tracks `Promise.all(...).then(() => setLoading(false))` — manual coordination of what Suspense composes automatically.
- A component that conditionally renders `<div>Loading...</div>` based on a parent-passed `isReady` prop — the loading concern is being plumbed through props instead of expressed in the tree.

The canonical resolution: make the data-fetching component `async`, throw promise (or use `use(promise)`), wrap callers in `<Suspense fallback={<Skeleton/>}>`. The fallback shape doubles as documentation of what's loading.

**Incorrect (manual loading state):**

```typescript
'use client'

function Dashboard() {
  const [stats, setStats] = useState(null)
  const [users, setUsers] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([fetchStats(), fetchUsers()])
      .then(([s, u]) => {
        setStats(s)
        setUsers(u)
        setLoading(false)
      })
  }, [])

  if (loading) return <DashboardSkeleton />

  return (
    <div>
      <Stats data={stats} />
      <UserList users={users} />
    </div>
  )
}
```

**Correct (Suspense with async components):**

```typescript
import { Suspense } from 'react'

function Dashboard() {
  return (
    <div>
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>
      <Suspense fallback={<UserListSkeleton />}>
        <UserList />
      </Suspense>
    </div>
  )
}

async function Stats() {
  const stats = await fetchStats()
  return <StatsDisplay data={stats} />
}

async function UserList() {
  const users = await fetchUsers()
  return <UserListDisplay users={users} />
}
// Each section loads independently with its own skeleton
```

**Benefits:**
- Declarative loading states
- Independent loading per section
- No manual loading state management
- Automatic error boundary integration
