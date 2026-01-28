---
title: Wrap Expensive Components with memo()
impact: MEDIUM
impactDescription: prevents cascading re-renders
tags: render, memo, optimization, re-renders, react
---

## Wrap Expensive Components with memo()

React.memo() prevents re-renders when props haven't changed. Use it for components that render frequently with the same props.

**Incorrect (re-renders on every parent render):**

```tsx
function Dashboard() {
  const [count, setCount] = useState(0)

  return (
    <View>
      <Text>{count}</Text>
      <Button onPress={() => setCount(c => c + 1)} title="Increment" />

      {/* These re-render on every count change */}
      <ExpensiveChart data={chartData} />
      <UserProfile user={user} />
      <NotificationsList notifications={notifications} />
    </View>
  )
}

function ExpensiveChart({ data }) {
  // Expensive render logic
  return <Chart data={data} />
}
```

**Correct (memoized expensive components):**

```tsx
function Dashboard() {
  const [count, setCount] = useState(0)

  return (
    <View>
      <Text>{count}</Text>
      <Button onPress={() => setCount(c => c + 1)} title="Increment" />

      {/* These only re-render when their props change */}
      <MemoizedChart data={chartData} />
      <MemoizedUserProfile user={user} />
      <MemoizedNotificationsList notifications={notifications} />
    </View>
  )
}

const MemoizedChart = memo(function ExpensiveChart({ data }) {
  return <Chart data={data} />
})

const MemoizedUserProfile = memo(function UserProfile({ user }) {
  return <Profile user={user} />
})

const MemoizedNotificationsList = memo(function NotificationsList({
  notifications
}) {
  return <List items={notifications} />
})
```

**With custom comparison:**

```tsx
const MemoizedItem = memo(
  function Item({ item, onPress }) {
    return (
      <TouchableOpacity onPress={onPress}>
        <Text>{item.name}</Text>
      </TouchableOpacity>
    )
  },
  // Custom comparison: only re-render if item.id changes
  (prevProps, nextProps) => prevProps.item.id === nextProps.item.id
)
```

**Ensure callbacks are stable:**

```tsx
function Parent() {
  // Without useCallback, this breaks memo
  const handlePress = useCallback((id) => {
    console.log('Pressed:', id)
  }, [])

  return <MemoizedChild onPress={handlePress} />
}

const MemoizedChild = memo(function Child({ onPress }) {
  return <TouchableOpacity onPress={() => onPress(1)}>
    <Text>Press me</Text>
  </TouchableOpacity>
})
```

**When to use memo():**
- List item components
- Charts and visualizations
- Forms with many fields
- Components that render frequently
- Components with expensive render logic

**When NOT to use memo():**
- Simple components (comparison overhead > render cost)
- Components that always receive new props
- Components that rarely re-render

Reference: [React memo Documentation](https://react.dev/reference/react/memo)
