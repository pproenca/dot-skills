---
title: Stabilize Callbacks with useCallback
impact: MEDIUM
impactDescription: prevents unnecessary re-renders in children
tags: tuistate, usecallback, memoization, performance, hooks
---

## Stabilize Callbacks with useCallback

Use `useCallback` to memoize callback functions passed to child components. This prevents children from re-rendering when parent state changes.

**Incorrect (new function on every render):**

```typescript
function App() {
  const [items, setItems] = useState<string[]>([])

  // New function created on every render
  const handleSelect = (item: string) => {
    setItems(prev => [...prev, item])
  }

  return (
    <Box flexDirection="column">
      <SelectList onSelect={handleSelect} />
      <SelectedItems items={items} />
    </Box>
  )
}
// SelectList re-renders whenever items changes
```

**Correct (stable callback reference):**

```typescript
function App() {
  const [items, setItems] = useState<string[]>([])

  // Same function reference between renders
  const handleSelect = useCallback((item: string) => {
    setItems(prev => [...prev, item])
  }, [])  // Empty deps - function never changes

  return (
    <Box flexDirection="column">
      <SelectList onSelect={handleSelect} />
      <SelectedItems items={items} />
    </Box>
  )
}
```

**With dependencies:**

```typescript
function SearchableList({ filter }: { filter: string }) {
  const [selected, setSelected] = useState<string | null>(null)

  const handleSelect = useCallback((item: string) => {
    if (item.includes(filter)) {
      setSelected(item)
    }
  }, [filter])  // Recreate when filter changes

  return <SelectList onSelect={handleSelect} />
}
```

**When NOT to use this pattern:**
- For callbacks not passed to child components
- When the component is already fast and memoization adds complexity
- With inline handlers in simple components

Reference: [React Documentation - useCallback](https://react.dev/reference/react/useCallback)
