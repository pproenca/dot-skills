---
title: Use Stable Keys for List Rendering Performance
impact: HIGH
impactDescription: O(n) DOM mutations reduced to O(1) moves
tags: render, keys, reconciliation, lists, dom
---

## Use Stable Keys for List Rendering Performance

Array index keys cause React's reconciler to treat every element as changed when items are reordered, inserted, or removed. This triggers full DOM teardown and rebuild for every item below the change point. Stable unique IDs let React match elements across renders and perform minimal DOM moves.

**Incorrect (index keys force full reconciliation on reorder):**

```tsx
interface Notification {
  id: string
  message: string
  timestamp: number
  priority: "low" | "medium" | "high"
}

function NotificationFeed({ notifications }: { notifications: Notification[] }) {
  const sorted = [...notifications].sort((a, b) => b.timestamp - a.timestamp)

  return (
    <ul>
      {sorted.map((notification, index) => (
        <li key={index}> {/* reorder changes every key — full DOM rebuild */}
          <NotificationCard notification={notification} />
        </li>
      ))}
    </ul>
  )
}
```

**Correct (stable ID keys enable minimal DOM moves):**

```tsx
interface Notification {
  id: string
  message: string
  timestamp: number
  priority: "low" | "medium" | "high"
}

function NotificationFeed({ notifications }: { notifications: Notification[] }) {
  const sorted = [...notifications].sort((a, b) => b.timestamp - a.timestamp)

  return (
    <ul>
      {sorted.map((notification) => (
        <li key={notification.id}>
          <NotificationCard notification={notification} />
        </li>
      ))}
    </ul>
  )
}
```

Reference: [React — Rendering Lists](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key)
