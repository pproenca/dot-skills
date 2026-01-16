---
title: Follow Rules of React for Compiler Compatibility
impact: HIGH
impactDescription: enables compiler optimization, prevents silent failures
tags: compiler, rules-of-react, purity, hooks
---

## Follow Rules of React for Compiler Compatibility

React Compiler assumes components follow the Rules of React. Violating these rules causes the compiler to skip optimization or produce incorrect output. Code that "worked" before may break when compiled.

**Incorrect (violates Rules of React):**

```tsx
// Mutating props
function BadComponent({ items }: { items: Item[] }) {
  items.sort((a, b) => a.name.localeCompare(b.name))  // Mutates prop!
  return <List items={items} />
}

// Reading from mutable external state during render
let globalCounter = 0
function CounterDisplay() {
  globalCounter++  // Side effect during render!
  return <span>{globalCounter}</span>
}

// Conditional hooks
function ConditionalHooks({ showExtra }: { showExtra: boolean }) {
  const [count, setCount] = useState(0)
  if (showExtra) {
    const [extra, setExtra] = useState('')  // Hook in conditional!
  }
  return <div>{count}</div>
}
```

**Correct (follows Rules of React):**

```tsx
// Create new sorted array
function GoodComponent({ items }: { items: Item[] }) {
  const sortedItems = [...items].sort((a, b) => a.name.localeCompare(b.name))
  return <List items={sortedItems} />
}

// Use state for mutable values
function CounterDisplay() {
  const [counter, setCounter] = useState(0)

  useEffect(() => {
    setCounter(c => c + 1)
  }, [])

  return <span>{counter}</span>
}

// Hooks at top level
function ConditionalContent({ showExtra }: { showExtra: boolean }) {
  const [count, setCount] = useState(0)
  const [extra, setExtra] = useState('')  // Always called

  return (
    <div>
      {count}
      {showExtra && <span>{extra}</span>}
    </div>
  )
}
```

**Rules the compiler enforces:**
- Components must be pure (same input = same output)
- Don't mutate props, state, or context
- Hooks must be called unconditionally at the top level
- Don't call hooks inside loops, conditions, or nested functions

Reference: [Rules of React](https://react.dev/reference/rules)
