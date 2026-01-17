---
title: Use useCallback for Stable Function References
impact: MEDIUM
impactDescription: prevents child re-renders from reference changes
tags: memo, useCallback, performance, callbacks
---

## Use useCallback for Stable Function References

Wrap callbacks in useCallback when passing them to memoized children. Without stable references, memo() is ineffective.

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
