---
title: Read Flame Charts to Identify Hot Render Paths
impact: MEDIUM
impactDescription: identifies exact function causing 80% of render time
tags: profile, flame-chart, chrome-devtools, hot-path
---

## Read Flame Charts to Identify Hot Render Paths

Flame charts visualize the call stack over time, making it immediately visible which function consumes the most CPU during a render. The widest bar is the hot path — the single call responsible for most of the frame time. Without reading flame charts, developers optimize random functions instead of the dominant cost.

**Incorrect (optimizing without flame chart data):**

```tsx
// Developer blindly memoizes the parent component
const OrderHistory = memo(function OrderHistory({ orders }: { orders: Order[] }) {
  const sortedOrders = [...orders].sort(
    (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
  )

  return (
    <div>
      {sortedOrders.map((order) => (
        <OrderRow key={order.id} order={order} />
      ))}
    </div>
  )
})

// The actual bottleneck is inside OrderRow's date formatting
// called 500 times per render — never investigated
function OrderRow({ order }: { order: Order }) {
  const formattedDate = new Intl.DateTimeFormat("en-GB", {
    dateStyle: "full",
    timeStyle: "long",
    timeZone: order.customerTimezone, // creates new formatter per row
  }).format(order.createdAt)

  return (
    <tr>
      <td>{order.id}</td>
      <td>{formattedDate}</td>
      <td>${order.total.toFixed(2)}</td>
    </tr>
  )
}
```

**Correct (flame chart reveals the hot path, fix targets it):**

```tsx
// Flame chart showed: Intl.DateTimeFormat constructor = 85% of render time
// Fix: cache formatters by timezone to avoid repeated construction

const formatterCache = new Map<string, Intl.DateTimeFormat>()

function getDateFormatter(timezone: string): Intl.DateTimeFormat {
  let formatter = formatterCache.get(timezone)
  if (!formatter) {
    formatter = new Intl.DateTimeFormat("en-GB", {
      dateStyle: "full",
      timeStyle: "long",
      timeZone: timezone,
    })
    formatterCache.set(timezone, formatter)
  }
  return formatter
}

function OrderRow({ order }: { order: Order }) {
  const formattedDate = getDateFormatter(order.customerTimezone).format(
    order.createdAt
  )

  return (
    <tr>
      <td>{order.id}</td>
      <td>{formattedDate}</td>
      <td>${order.total.toFixed(2)}</td>
    </tr>
  )
}

// No memo needed on OrderHistory — the hot path was inside OrderRow
function OrderHistory({ orders }: { orders: Order[] }) {
  const sortedOrders = [...orders].sort(
    (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
  )

  return (
    <div>
      {sortedOrders.map((order) => (
        <OrderRow key={order.id} order={order} />
      ))}
    </div>
  )
}
```

Reference: [Chrome DevTools — Analyze Runtime Performance](https://developer.chrome.com/docs/devtools/performance)
