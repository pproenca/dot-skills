---
title: Ensure Selectors Return Stable References
impact: CRITICAL
impactDescription: prevents re-renders when content unchanged
tags: select, stability, references, arrays, objects
---

## Ensure Selectors Return Stable References

Selectors that return new arrays or objects on every call trigger re-renders even when the content is identical. Zustand's strict equality check sees `[] !== []` and `{} !== {}`.

**Incorrect (creates new array on every call):**

```typescript
function ActiveUsers() {
  // .filter() creates new array every time
  const activeUsers = useUserStore((state) =>
    state.users.filter((u) => u.isActive)
  )
  // Re-renders on ANY store change, not just when active users change
  return <UserList users={activeUsers} />
}
```

**Correct (use useShallow for derived arrays):**

```typescript
import { useShallow } from 'zustand/react/shallow'

function ActiveUsers() {
  // useShallow compares array contents
  const activeUsers = useUserStore(
    useShallow((state) => state.users.filter((u) => u.isActive))
  )
  // Only re-renders when the filtered result actually changes
  return <UserList users={activeUsers} />
}
```

**Alternative (memoize in component):**

```typescript
function ActiveUsers() {
  const users = useUserStore((state) => state.users)
  // Memoize derived value in component
  const activeUsers = useMemo(
    () => users.filter((u) => u.isActive),
    [users]
  )
  return <UserList users={activeUsers} />
}
```

**Alternative (store the filtered list):**

```typescript
// If filtering is expensive or used in many components
const useActiveUsers = () => useUserStore(
  useShallow((state) => state.users.filter((u) => u.isActive))
)
```

Reference: [Zustand - Prevent Rerenders with useShallow](https://zustand.docs.pmnd.rs/guides/prevent-rerenders-with-use-shallow)
