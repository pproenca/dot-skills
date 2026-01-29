---
title: Avoid Returning New Objects from Selectors
impact: HIGH
impactDescription: prevents re-renders when values unchanged
tags: render, objects, references, selectors
---

## Avoid Returning New Objects from Selectors

Selectors that return new object literals trigger re-renders on every store update because `{} !== {}`. Return primitives or use `useShallow` for object selections.

**Incorrect (new object on every call):**

```typescript
function UserBadge() {
  // Creates new object literal on every store update
  const user = useUserStore((state) => ({
    displayName: `${state.firstName} ${state.lastName}`,
    initials: `${state.firstName[0]}${state.lastName[0]}`,
  }))
  // Re-renders on ANY state change
  return <Badge name={user.displayName} initials={user.initials} />
}
```

**Correct (separate atomic selectors):**

```typescript
function UserBadge() {
  const firstName = useUserStore((s) => s.firstName)
  const lastName = useUserStore((s) => s.lastName)

  // Compute derived values in component
  const displayName = `${firstName} ${lastName}`
  const initials = `${firstName[0]}${lastName[0]}`

  return <Badge name={displayName} initials={initials} />
}
```

**Alternative (useShallow for object returns):**

```typescript
import { useShallow } from 'zustand/react/shallow'

function UserBadge() {
  const { firstName, lastName } = useUserStore(
    useShallow((state) => ({
      firstName: state.firstName,
      lastName: state.lastName,
    }))
  )

  const displayName = `${firstName} ${lastName}`
  const initials = `${firstName[0]}${lastName[0]}`

  return <Badge name={displayName} initials={initials} />
}
```

**Alternative (memoized selector hook):**

```typescript
const useUserBadgeData = () => {
  const firstName = useUserStore((s) => s.firstName)
  const lastName = useUserStore((s) => s.lastName)

  return useMemo(() => ({
    displayName: `${firstName} ${lastName}`,
    initials: `${firstName[0]}${lastName[0]}`,
  }), [firstName, lastName])
}
```

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
