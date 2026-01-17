---
title: Use Functional Updates for State Derived from Previous Value
impact: HIGH
impactDescription: prevents stale closure bugs and race conditions
tags: state, functional-updates, closures, setState, increment
---

## Use Functional Updates for State Derived from Previous Value

When the new state depends on the previous state (incrementing, toggling, appending), use functional updates. Direct state references in closures can be stale.

**Incorrect (stale closure):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Counter() {
  const [count, setCount] = useQueryState('count', parseAsInteger.withDefault(0))

  const incrementTwice = () => {
    setCount(count + 1) // Uses stale `count`
    setCount(count + 1) // Still uses same stale `count`
    // Result: increments by 1, not 2
  }

  return <button onClick={incrementTwice}>+2</button>
}
```

**Correct (functional update):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Counter() {
  const [count, setCount] = useQueryState('count', parseAsInteger.withDefault(0))

  const incrementTwice = () => {
    setCount(c => c + 1) // Gets latest value
    setCount(c => c + 1) // Gets updated value
    // Result: correctly increments by 2
  }

  return <button onClick={incrementTwice}>+2</button>
}
```

**More examples:**

```tsx
// Toggle boolean
const [enabled, setEnabled] = useQueryState('enabled', parseAsBoolean.withDefault(false))
setEnabled(e => !e)

// Append to array
const [tags, setTags] = useQueryState(
  'tags',
  parseAsArrayOf(parseAsString).withDefault([])
)
setTags(t => [...t, 'new-tag'])

// Remove from array
setTags(t => t.filter(tag => tag !== 'remove-me'))
```

Reference: [nuqs State Updates](https://nuqs.dev/docs)
