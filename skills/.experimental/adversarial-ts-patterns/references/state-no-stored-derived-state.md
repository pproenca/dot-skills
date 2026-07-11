---
title: Do not store state derivable from existing props or state
tags: state, derived-state, react, redundancy
---

## Do not store state derivable from existing props or state

The wrong default is `useState` plus a synchronizing `useEffect` for a value that is a pure function of other props or state — `fullName` from `firstName + lastName`, `visibleItems` from `items` and `filter`. Stored copies drift the moment one write path forgets the sync, and the effect version renders once with the stale value before correcting itself. A derived value is a `const` computed during render; if the computation is measurably expensive, it is a `useMemo` — still not state.

**Evidence of violation:** a state variable written inside a `useEffect` whose new value is computed purely from other props/state in the same component (no external system involved), or a state initializer that copies a prop which can change (`useState(props.value)` with no reset story). The external-system carve-out from the effect-chain rule applies here too — caching an async result is synchronization, not derivation.

**Incorrect (stored copy, synced by hand, one render stale):**

```tsx
const [items, setItems] = useState<Todo[]>([])
const [activeCount, setActiveCount] = useState(0)

useEffect(() => {
  setActiveCount(items.filter(t => !t.done).length)
}, [items])
```

**Correct (derive during render):**

```tsx
const [items, setItems] = useState<Todo[]>([])
const activeCount = items.filter(t => !t.done).length
```

Reference: [react.dev — Choosing the State Structure (avoid redundant state)](https://react.dev/learn/choosing-the-state-structure#avoid-redundant-state)
