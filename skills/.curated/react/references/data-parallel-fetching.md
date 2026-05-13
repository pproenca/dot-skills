---
title: Independent fetches run concurrently — sequential `await` is a waterfall
impact: MEDIUM-HIGH
impactDescription: collapses N sequential `await`s into max(latencies); 2-5x speedup on multi-fetch pages
tags: data, parallel-fetching, waterfall, concurrent-await
---

## Independent fetches run concurrently — sequential `await` is a waterfall

**Pattern intent:** when two or more data requests don't depend on each other, they should be in flight at the same time. The pattern break is "sequential `await` for independent data" — the total cost becomes the sum of latencies instead of the max.

### Shapes to recognize

- Two or more `const x = await fetchX(); const y = await fetchY();` lines at the top of an async component where `y` doesn't reference `x`.
- A `for (const id of ids) { items.push(await fetchOne(id)) }` loop — each iteration's await blocks the next.
- Two `useQuery` hooks (TanStack Query) that fetch on mount, where neither depends on the other's result — the runtime already parallelizes them, but if a parent gates one behind the other's resolution, the same waterfall returns.
- A "loader" function in a route framework that does `const a = await get('/a'); const b = await get('/b');` — should be `Promise.all([get('/a'), get('/b')])`.
- A custom hook chaining `useEffect`s that read each other's `useState` results to "wait for the first fetch" — manual sequencing of work that could parallelize.

The canonical resolution: `const [a, b, c] = await Promise.all([fetchA(), fetchB(), fetchC()])` for hard dependencies; `Promise.allSettled` when each branch should tolerate the others' failures.

**Incorrect (sequential fetching):**

```typescript
async function Dashboard() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 150ms
  const analytics = await fetchAnalytics() // 300ms
  // Total: 650ms (sum of all)

  return (
    <div>
      <UserCard user={user} />
      <OrderList orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  )
}
```

**Correct (parallel fetching):**

```typescript
async function Dashboard() {
  const [user, orders, analytics] = await Promise.all([
    fetchUser(),       // 200ms
    fetchOrders(),     // 150ms (parallel)
    fetchAnalytics()   // 300ms (parallel)
  ])
  // Total: 300ms (max of all)

  return (
    <div>
      <UserCard user={user} />
      <OrderList orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  )
}
```

**With error handling:**

```typescript
async function Dashboard() {
  const results = await Promise.allSettled([
    fetchUser(),
    fetchOrders(),
    fetchAnalytics()
  ])

  const user = results[0].status === 'fulfilled' ? results[0].value : null
  const orders = results[1].status === 'fulfilled' ? results[1].value : []
  const analytics = results[2].status === 'fulfilled' ? results[2].value : null

  return (
    <div>
      {user ? <UserCard user={user} /> : <UserError />}
      <OrderList orders={orders} />
      {analytics && <AnalyticsChart data={analytics} />}
    </div>
  )
}
```
