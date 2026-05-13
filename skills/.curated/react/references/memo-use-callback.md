---
title: Stabilize a callback's identity only when something downstream depends on identity stability
impact: MEDIUM
impactDescription: prevents memoed children from re-rendering on every parent render; otherwise adds overhead without payoff
tags: memo, callback-stability, downstream-memo, ref-equality
---

## Stabilize a callback's identity only when something downstream depends on identity stability

**Pattern intent:** `useCallback` exists to keep a function's reference stable across renders. That only matters when a memoed child compares it with `===`, or an effect depends on it. Without such a consumer, `useCallback` is overhead.

### Shapes to recognize

- A `useCallback` wrapping a handler whose only consumer is a plain (non-memo'd) DOM element — `<button onClick={handler}>`. The reference doesn't matter.
- A `useCallback` whose deps array includes a value that changes every render — the callback is "stable" only between renders that never happen.
- A `useCallback([])` containing a closure over `state.x` — the closure is frozen to the first-render value of `x` (stale closure). The fix is the functional setter (see [`rstate-functional-updates.md`](rstate-functional-updates.md)), not a different memo strategy.
- A new project with `useCallback` on every handler — predates React Compiler v1.0; consider removing.
- A `useCallback` passed to a `memo`'d child whose other props (object/array) are inline — the memo skips on callback identity but renders anyway because of the other prop. Fix all unstable props or none.

The canonical resolution: reach for `useCallback` when the callback is consumed by `memo`, `useEffect`, or another hook that depends on referential equality — and only then. With React Compiler v1.0 enabled, most cases collapse to plain function declarations.

**Incorrect (new function reference on every render):**

```typescript
function Parent() {
  const [count, setCount] = useState(0)

  function handleClick() {
    console.log('clicked')
  }

  return (
    <div>
      <p>{count}</p>
      <button onClick={() => setCount(c => c + 1)}>Increment</button>
      <ExpensiveChild onClick={handleClick} />
    </div>
  )
}

const ExpensiveChild = memo(function ExpensiveChild({ onClick }) {
  // Re-renders every time Parent renders because handleClick is new
  return <button onClick={onClick}>Click me</button>
})
```

**Correct (stable callback with useCallback):**

```typescript
import { useCallback, memo, useState } from 'react'

function Parent() {
  const [count, setCount] = useState(0)

  const handleClick = useCallback(() => {
    console.log('clicked')
  }, [])  // Empty deps = stable reference

  return (
    <div>
      <p>{count}</p>
      <button onClick={() => setCount(c => c + 1)}>Increment</button>
      <ExpensiveChild onClick={handleClick} />
    </div>
  )
}

const ExpensiveChild = memo(function ExpensiveChild({ onClick }) {
  // Only re-renders if onClick reference changes
  return <button onClick={onClick}>Click me</button>
})
```

**Combine with functional setState:**

```typescript
const handleIncrement = useCallback(() => {
  setCount(c => c + 1)  // Functional form - no dependency on count
}, [])  // Stable forever
```

**Note:** If using [React Compiler v1.0+](https://react.dev/blog/2025/10/07/react-compiler-1), useCallback is handled automatically. Use manual useCallback only when the compiler can't optimize your case.

---

### In disguise — `useCallback` stabilized, but a *sibling* prop is inline-recreated and defeats the memo

The grep-friendly anti-pattern is a missing `useCallback` on a callback passed to a `memo`'d child. The more subtle disguise is when the developer *did* add the `useCallback` — but the same component also passes an inline object/array as another prop. Memo compares all props; one unstable prop defeats the whole skip.

**Incorrect — in disguise (callback is stable, but `options` is not):**

```typescript
const ExpensiveChild = memo(function ExpensiveChild({
  onClick,
  options,
}: {
  onClick: () => void
  options: { showHeader: boolean; sortBy: 'asc' | 'desc' }
}) {
  // expensive render
  return <div>{/* ... */}</div>
})

function Parent() {
  const [count, setCount] = useState(0)

  const handleClick = useCallback(() => {
    console.log('clicked')
  }, []) // ✅ stable

  return (
    <div>
      <button onClick={() => setCount((c) => c + 1)}>{count}</button>
      <ExpensiveChild
        onClick={handleClick}
        options={{ showHeader: true, sortBy: 'asc' }}  // ❌ new object every render
      />
    </div>
  )
}
// ExpensiveChild still re-renders on every Parent render. The useCallback
// achieves nothing because `options` reference changes every time.
```

**Correct — stabilize all unstable props, or hoist the constant outside:**

```typescript
// Option A — hoist the constant out of render if it never changes
const OPTIONS = { showHeader: true, sortBy: 'asc' as const }

function Parent() {
  const [count, setCount] = useState(0)
  const handleClick = useCallback(() => { console.log('clicked') }, [])
  return (
    <div>
      <button onClick={() => setCount((c) => c + 1)}>{count}</button>
      <ExpensiveChild onClick={handleClick} options={OPTIONS} />
    </div>
  )
}

// Option B — useMemo if options depends on state
function Parent({ sortBy }: { sortBy: 'asc' | 'desc' }) {
  const handleClick = useCallback(() => { console.log('clicked') }, [])
  const options = useMemo(() => ({ showHeader: true, sortBy }), [sortBy])
  return <ExpensiveChild onClick={handleClick} options={options} />
}
```

The lesson: `memo` + `useCallback` is an *all-or-nothing* contract. Stabilize every prop that participates in the comparison, or skip `memo` entirely. (Most codebases on React Compiler v1.0 can drop both the `memo` and the `useCallback`; the compiler handles it.)
