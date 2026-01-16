---
title: Memoize Expensive Child Components
impact: MEDIUM
impactDescription: prevents cascading re-renders in component trees
tags: render, memo, optimization, children
---

## Memoize Expensive Child Components

While React Compiler handles most memoization, wrapping expensive components with `memo()` can still help prevent re-renders when parent state changes don't affect the child.

**Incorrect (child re-renders on every parent update):**

```tsx
function Dashboard() {
  const [notifications, setNotifications] = useState(0)

  return (
    <div>
      <NotificationBell count={notifications} />
      <ExpensiveChart data={chartData} />  {/* Re-renders when notifications change */}
    </div>
  )
}

function ExpensiveChart({ data }: { data: ChartData }) {
  // 50ms render time
  return <canvas>{/* complex rendering */}</canvas>
}
```

**Correct (memo prevents unnecessary re-renders):**

```tsx
function Dashboard() {
  const [notifications, setNotifications] = useState(0)

  return (
    <div>
      <NotificationBell count={notifications} />
      <ExpensiveChart data={chartData} />  {/* Skips render if data unchanged */}
    </div>
  )
}

const ExpensiveChart = memo(function ExpensiveChart({ data }: { data: ChartData }) {
  // Only renders when data prop changes
  return <canvas>{/* complex rendering */}</canvas>
})
```

**With custom comparison:**

```tsx
const ExpensiveChart = memo(
  function ExpensiveChart({ data, options }: Props) {
    return <canvas>{/* complex rendering */}</canvas>
  },
  (prevProps, nextProps) => {
    // Only re-render if data length or options changed
    return (
      prevProps.data.length === nextProps.data.length &&
      prevProps.options.theme === nextProps.options.theme
    )
  }
)
```

**When memo helps:**
- Components with expensive render logic
- Components receiving stable props from frequently-updating parents
- List items rendered many times

Reference: [memo](https://react.dev/reference/react/memo)
