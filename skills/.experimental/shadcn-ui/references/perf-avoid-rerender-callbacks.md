---
title: Stabilize Callback Props to Prevent Re-renders
impact: LOW-MEDIUM
impactDescription: prevents cascading re-renders in list components
tags: perf, useCallback, re-render, callbacks, optimization
---

## Stabilize Callback Props to Prevent Re-renders

Use useCallback for event handlers passed to shadcn/ui components in lists. Unstable callbacks cause all child components to re-render on parent state changes.

**Incorrect (new function on every render):**

```tsx
function UserList({ users }) {
  const [selected, setSelected] = useState<string[]>([])

  return (
    <div>
      {users.map((user) => (
        <Card key={user.id}>
          <CardContent>
            <Checkbox
              checked={selected.includes(user.id)}
              onCheckedChange={(checked) => {  // New function every render
                setSelected((prev) =>
                  checked ? [...prev, user.id] : prev.filter((id) => id !== user.id)
                )
              }}
            />
            {user.name}
          </CardContent>
        </Card>
      ))}
    </div>
  )
  // Every Checkbox re-renders when any selection changes
}
```

**Correct (stable callback):**

```tsx
import { useCallback } from "react"

function UserList({ users }) {
  const [selected, setSelected] = useState<string[]>([])

  const handleCheckedChange = useCallback((userId: string, checked: boolean) => {
    setSelected((prev) =>
      checked ? [...prev, userId] : prev.filter((id) => id !== userId)
    )
  }, [])

  return (
    <div>
      {users.map((user) => (
        <UserCard
          key={user.id}
          user={user}
          isSelected={selected.includes(user.id)}
          onCheckedChange={handleCheckedChange}
        />
      ))}
    </div>
  )
}

const UserCard = memo(function UserCard({ user, isSelected, onCheckedChange }) {
  return (
    <Card>
      <CardContent>
        <Checkbox
          checked={isSelected}
          onCheckedChange={(checked) => onCheckedChange(user.id, checked)}
        />
        {user.name}
      </CardContent>
    </Card>
  )
})
// Only changed cards re-render
```

Reference: [React useCallback](https://react.dev/reference/react/useCallback)
