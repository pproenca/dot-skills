---
title: Use Functional State Updates to Avoid Stale Closures
impact: HIGH
impactDescription: prevents stale state bugs in callbacks
tags: tuistate, usestate, closures, callbacks, hooks
---

## Use Functional State Updates to Avoid Stale Closures

Use the functional form of setState when the new value depends on the previous value. This prevents stale closure bugs in event handlers and callbacks.

**Incorrect (stale closure):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  useInput((input) => {
    if (input === '+') {
      setCount(count + 1)  // Captures count at callback creation time
    }
    if (input === '-') {
      setCount(count - 1)  // Stale if multiple presses
    }
  })

  return <Text>Count: {count}</Text>
}
// Rapidly pressing '+' may only increment once due to stale closure
```

**Correct (functional update):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  useInput((input) => {
    if (input === '+') {
      setCount(c => c + 1)  // Always uses latest value
    }
    if (input === '-') {
      setCount(c => c - 1)
    }
  })

  return <Text>Count: {count}</Text>
}
```

**Complex state updates:**

```typescript
interface ListState {
  items: string[]
  selectedIndex: number
}

function SelectList() {
  const [state, setState] = useState<ListState>({
    items: ['Apple', 'Banana', 'Cherry'],
    selectedIndex: 0
  })

  useInput((input, key) => {
    if (key.upArrow) {
      setState(s => ({
        ...s,
        selectedIndex: Math.max(0, s.selectedIndex - 1)
      }))
    }

    if (key.downArrow) {
      setState(s => ({
        ...s,
        selectedIndex: Math.min(s.items.length - 1, s.selectedIndex + 1)
      }))
    }
  })

  return (
    <Box flexDirection="column">
      {state.items.map((item, i) => (
        <Text key={i} inverse={i === state.selectedIndex}>
          {item}
        </Text>
      ))}
    </Box>
  )
}
```

Reference: [React Documentation - useState](https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state)
