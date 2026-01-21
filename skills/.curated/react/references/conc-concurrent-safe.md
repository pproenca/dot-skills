---
title: Write Concurrent-Safe Components
impact: MEDIUM-HIGH
impactDescription: prevents bugs in concurrent rendering
tags: conc, concurrent, safe, rendering
---

## Write Concurrent-Safe Components

React may pause, interrupt, and restart renders. Avoid side effects during render and ensure components are idempotent.

**Incorrect (side effects during render):**

```typescript
let globalId = 0

function UserCard({ user }) {
  // Side effect during render - will run multiple times in concurrent mode
  const id = globalId++
  logView(user.id)  // Analytics called multiple times!

  return (
    <div id={`card-${id}`}>
      {user.name}
    </div>
  )
}
```

**Correct (side effects in effects, stable IDs):**

```typescript
import { useId, useEffect } from 'react'

function UserCard({ user }) {
  const id = useId()  // Stable across renders

  useEffect(() => {
    // Side effects in useEffect - runs once after commit
    logView(user.id)
  }, [user.id])

  return (
    <div id={id}>
      {user.name}
    </div>
  )
}
```

**Concurrent-safe patterns:**

```typescript
// ✅ Pure calculations during render
const fullName = `${firstName} ${lastName}`

// ✅ Memoized expensive calculations
const sorted = useMemo(() => items.sort(compare), [items])

// ✅ Stable references with useId
const inputId = useId()

// ❌ Mutations during render
items.push(newItem)

// ❌ Subscriptions during render
window.addEventListener('resize', handler)

// ❌ External state reads without sync
const width = window.innerWidth
```
