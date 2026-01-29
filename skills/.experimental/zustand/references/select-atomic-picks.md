---
title: Use Atomic Selectors for Single Values
impact: CRITICAL
impactDescription: O(1) equality check, minimal re-render scope
tags: select, atomic, performance, primitives
---

## Use Atomic Selectors for Single Values

Zustand uses strict equality (===) by default. Atomic selectors that return single primitive values are the most efficient because equality checks are instant and precise.

**Incorrect (returns object, always re-renders):**

```typescript
function UserProfile() {
  // Creates new object on every store update
  const user = useBearStore((state) => ({
    name: state.userName,
    email: state.userEmail,
  }))
  // Re-renders on ANY state change because {} !== {}
  return <div>{user.name} - {user.email}</div>
}
```

**Correct (atomic selectors):**

```typescript
function UserProfile() {
  // Each selector returns a primitive
  const name = useBearStore((state) => state.userName)
  const email = useBearStore((state) => state.userEmail)
  // Only re-renders when name or email actually changes
  return <div>{name} - {email}</div>
}
```

**Alternative (multiple values with useShallow):**

```typescript
import { useShallow } from 'zustand/react/shallow'

function UserProfile() {
  const { userName, userEmail } = useBearStore(
    useShallow((state) => ({
      userName: state.userName,
      userEmail: state.userEmail,
    }))
  )
  return <div>{userName} - {userEmail}</div>
}
```

**When to use each approach:**
- **Atomic selectors**: Default choice, best performance
- **useShallow**: When you need 3+ values and want cleaner code

Reference: [Working with Zustand - TkDodo](https://tkdodo.eu/blog/working-with-zustand)
