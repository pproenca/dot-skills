---
title: Memo Children Affected by Parent Store Updates
impact: HIGH
impactDescription: prevents cascading re-renders to child tree
tags: render, memo, children, optimization
---

## Memo Children Affected by Parent Store Updates

When a parent component subscribes to the store, all children re-render by default. Use `React.memo` on expensive children that don't need the updated state.

**Incorrect (children re-render with parent):**

```typescript
function Dashboard() {
  const notifications = useNotificationStore((s) => s.notifications)
  // Every notification update re-renders entire dashboard including children
  return (
    <div>
      <NotificationBadge count={notifications.length} />
      <ExpensiveChart />      {/* Re-renders unnecessarily */}
      <ExpensiveTable />      {/* Re-renders unnecessarily */}
      <ExpensiveCalendar />   {/* Re-renders unnecessarily */}
    </div>
  )
}
```

**Correct (memoized children):**

```typescript
const ExpensiveChart = memo(function ExpensiveChart() {
  // Has its own store subscription
  const chartData = useChartStore((s) => s.data)
  return <Chart data={chartData} />
})

const ExpensiveTable = memo(function ExpensiveTable() {
  const tableData = useTableStore((s) => s.rows)
  return <Table rows={tableData} />
})

const ExpensiveCalendar = memo(function ExpensiveCalendar() {
  const events = useCalendarStore((s) => s.events)
  return <Calendar events={events} />
})

function Dashboard() {
  const notifications = useNotificationStore((s) => s.notifications)
  // Children only re-render when their own subscriptions change
  return (
    <div>
      <NotificationBadge count={notifications.length} />
      <ExpensiveChart />
      <ExpensiveTable />
      <ExpensiveCalendar />
    </div>
  )
}
```

**Note:** React re-renders children by default. This is fine for most components. Only use `memo` when:
- The child is expensive to render
- The child doesn't need the parent's updated state
- Profiling shows the re-renders are a bottleneck

Reference: [Zustand GitHub Discussions](https://github.com/pmndrs/zustand/discussions/2642)
