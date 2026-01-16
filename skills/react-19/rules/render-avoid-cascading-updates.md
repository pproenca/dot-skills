---
title: Avoid Cascading State Updates in Effects
impact: MEDIUM
impactDescription: prevents double renders and layout thrashing
tags: render, effects, state, performance
---

## Avoid Cascading State Updates in Effects

Setting state in effects that depend on other state causes cascading re-renders. Derive state during render or use event handlers instead.

**Incorrect (cascading updates, multiple renders):**

```tsx
function FilteredList({ items, filter }: Props) {
  const [filteredItems, setFilteredItems] = useState<Item[]>([])

  useEffect(() => {
    setFilteredItems(items.filter(i => matchesFilter(i, filter)))
  }, [items, filter])
  // Render 1: empty filteredItems
  // Effect runs, sets state
  // Render 2: with filtered items

  return <List items={filteredItems} />
}
```

**Correct (derive during render):**

```tsx
function FilteredList({ items, filter }: Props) {
  const filteredItems = items.filter(i => matchesFilter(i, filter))
  // Single render with correct data

  return <List items={filteredItems} />
}
```

**For expensive computations:**

```tsx
function FilteredList({ items, filter }: Props) {
  const filteredItems = useMemo(
    () => items.filter(i => matchesFilter(i, filter)),
    [items, filter]
  )

  return <List items={filteredItems} />
}
```

**When effects are appropriate:**
- Synchronizing with external systems
- Subscriptions and event listeners
- Data fetching (prefer Server Components or libraries)

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
