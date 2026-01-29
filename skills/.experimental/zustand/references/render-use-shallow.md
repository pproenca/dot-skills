---
title: Use useShallow for Multi-Property Selections
impact: HIGH
impactDescription: prevents re-renders when content unchanged
tags: render, useShallow, shallow-comparison, performance
---

## Use useShallow for Multi-Property Selections

When selecting multiple properties as an object, wrap your selector with `useShallow` to use shallow comparison instead of strict equality. This prevents re-renders when the selected values haven't actually changed.

**Incorrect (strict equality on object):**

```typescript
function UserCard() {
  // Creates new object on every store update
  const { name, email, avatar } = useUserStore((state) => ({
    name: state.name,
    email: state.email,
    avatar: state.avatar,
  }))
  // Re-renders when ANY state changes because {} !== {}
  return (
    <div>
      <img src={avatar} alt={name} />
      <p>{name}</p>
      <p>{email}</p>
    </div>
  )
}
```

**Correct (shallow comparison with useShallow):**

```typescript
import { useShallow } from 'zustand/react/shallow'

function UserCard() {
  const { name, email, avatar } = useUserStore(
    useShallow((state) => ({
      name: state.name,
      email: state.email,
      avatar: state.avatar,
    }))
  )
  // Only re-renders when name, email, or avatar actually changes
  return (
    <div>
      <img src={avatar} alt={name} />
      <p>{name}</p>
      <p>{email}</p>
    </div>
  )
}
```

**Alternative (array selection with useShallow):**

```typescript
function BearStats() {
  // Works with arrays too
  const [bears, fish, honey] = useStore(
    useShallow((state) => [state.bears, state.fish, state.honey])
  )

  return <div>Bears: {bears}, Fish: {fish}, Honey: {honey}</div>
}
```

**When to use:**
- Selecting 2+ properties that you need as destructured values
- Selectors that return arrays (filter, map results)
- Any selector that creates a new reference

Reference: [Zustand - Prevent Rerenders with useShallow](https://zustand.docs.pmnd.rs/guides/prevent-rerenders-with-use-shallow)
