---
title: Use Suspense for Declarative Loading States
impact: HIGH
impactDescription: cleaner code, coordinated loading UI
tags: data, suspense, loading, declarative
---

## Use Suspense for Declarative Loading States

Wrap data-fetching components in Suspense to declare loading UI. This eliminates manual loading state management.

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
