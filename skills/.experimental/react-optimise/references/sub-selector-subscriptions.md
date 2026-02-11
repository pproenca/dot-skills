---
title: Use Selector-Based Subscriptions for Granular Updates
impact: MEDIUM-HIGH
impactDescription: reduces re-renders to only affected components
tags: sub, selector, subscription, store
---

## Use Selector-Based Subscriptions for Granular Updates

Subscribing to an entire store object re-renders the component whenever any field changes, even fields the component never reads. Selector functions narrow the subscription to specific slices, so the component only re-renders when its selected value changes.

**Incorrect (re-renders on any store field change):**

```tsx
import { useSyncExternalStore } from "react"
import { dashboardStore } from "./store"

function OrderCount() {
  const storeState = useSyncExternalStore(
    dashboardStore.subscribe,
    dashboardStore.getSnapshot // returns entire { orders, filters, selectedTab, notifications }
  )

  // Re-renders when filters, selectedTab, or notifications change
  return <span className="badge">{storeState.orders.length} orders</span>
}

function FilterPanel() {
  const storeState = useSyncExternalStore(
    dashboardStore.subscribe,
    dashboardStore.getSnapshot
  )

  // Re-renders when orders or notifications change
  return <div>{storeState.filters.map((f) => <FilterChip key={f.id} filter={f} />)}</div>
}
```

**Correct (re-renders only when selected slice changes):**

```tsx
import { useSyncExternalStore } from "react"
import { dashboardStore } from "./store"

function useStoreSelector<T>(selector: (state: DashboardState) => T): T {
  return useSyncExternalStore(
    dashboardStore.subscribe,
    () => selector(dashboardStore.getSnapshot())
  )
}

function OrderCount() {
  const orderCount = useStoreSelector((state) => state.orders.length)

  return <span className="badge">{orderCount} orders</span>
}

function FilterPanel() {
  const filters = useStoreSelector((state) => state.filters)

  return <div>{filters.map((f) => <FilterChip key={f.id} filter={f} />)}</div>
}
```

Reference: [React Docs — useSyncExternalStore](https://react.dev/reference/react/useSyncExternalStore)
