---
title: Keep render pure — never mutate, subscribe, or read external state during render
impact: MEDIUM-HIGH
impactDescription: prevents double-fire bugs, stale reads, and lost subscriptions under React's concurrent scheduler
tags: conc, render-purity, side-effects, idempotent-render
---

## Keep render pure — never mutate, subscribe, or read external state during render

**Pattern intent:** React may pause, abandon, and restart a render. A component's function body must be a pure mapping from props/state to JSX. Anything observable from the outside (counters, analytics, DOM subscriptions, network calls, mutable reads) belongs in an effect, ref, or external store, never in render.

### Shapes to recognize

- A `let counter = 0` at module scope, incremented inside a component's body each render — analytics or ID schemes that double-fire under concurrent mode.
- `analytics.track(...)`, `logger.info(...)`, `console.warn` calls inside the function body, intended to fire once per logical mount.
- `window.addEventListener` or `document.addEventListener` written directly in the component body — never cleaned up, accumulates on every render.
- `array.push(item)` / `obj.foo = bar` mutating a prop or shared module-level value during render.
- Reading `window.innerWidth`, `document.cookie`, or other browser-only globals directly in render — works once, breaks under SSR and breaks again under interrupted renders.
- A `Math.random()` or `Date.now()` value persisted into a `useState` initializer's body (the unwrapped form) instead of the lazy initializer — value changes on every render attempt.

The canonical resolution: side effects go in `useEffect`/`useLayoutEffect`; external state reads go through `useSyncExternalStore`; stable identifiers come from `useId` or `useRef`; "once on mount" intent is rare and should be expressed via an effect with an empty deps and ref-guarded body, not via render-body code.

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
const sorted = useMemo(() => [...items].sort(compare), [items])

// ✅ Stable references with useId
const inputId = useId()

// ❌ Mutations during render
items.push(newItem)

// ❌ Subscriptions during render
window.addEventListener('resize', handler)

// ❌ External state reads without sync
const width = window.innerWidth
```
