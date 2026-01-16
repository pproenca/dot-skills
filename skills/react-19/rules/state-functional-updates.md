---
title: Use Functional setState for Derived Updates
impact: MEDIUM
impactDescription: prevents stale closure bugs, enables stable callbacks
tags: state, useState, closures, callbacks
---

## Use Functional setState for Derived Updates

When updating state based on the previous value, use the functional form. This prevents stale closure bugs and allows callbacks to remain stable across renders.

**Incorrect (stale closure, unstable callback):**

```tsx
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(count + 1)  // Captures stale count
  }, [count])  // Must include count, callback recreated every render

  return (
    <div>
      <span>{count}</span>
      <ExpensiveChild onIncrement={increment} />  {/* Re-renders on every count change */}
    </div>
  )
}
```

**Correct (no stale closure, stable callback):**

```tsx
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(c => c + 1)  // Always gets current value
  }, [])  // Never recreated

  return (
    <div>
      <span>{count}</span>
      <ExpensiveChild onIncrement={increment} />  {/* Doesn't re-render */}
    </div>
  )
}
```

**Batch multiple updates:**

```tsx
function Form() {
  const [formState, setFormState] = useState({ name: '', email: '', valid: false })

  const handleChange = (field: string, value: string) => {
    setFormState(prev => ({
      ...prev,
      [field]: value,
      valid: validateField(field, value) && prev.valid
    }))
  }

  return <input onChange={e => handleChange('name', e.target.value)} />
}
```

Reference: [useState](https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state)
