---
title: Always Use Selectors Never Subscribe to Entire Store
impact: CRITICAL
impactDescription: prevents unnecessary re-renders on any state change
tags: select, selectors, performance, re-renders
---

## Always Use Selectors Never Subscribe to Entire Store

Never call the store hook without a selector. Subscribing to the entire store causes your component to re-render on any state change, even if the values you use didn't change.

**Incorrect (subscribes to entire store):**

```typescript
const useBearStore = create<BearState>((set) => ({
  bears: 0,
  fish: 0,
  honey: 100,
  increasePopulation: () => set((s) => ({ bears: s.bears + 1 })),
}))

function BearCounter() {
  // Subscribes to entire store
  const { bears } = useBearStore()
  // Re-renders when fish or honey changes too!
  return <div>Bears: {bears}</div>
}
```

**Correct (uses selector):**

```typescript
function BearCounter() {
  // Subscribes only to bears
  const bears = useBearStore((state) => state.bears)
  // Only re-renders when bears changes
  return <div>Bears: {bears}</div>
}
```

**Alternative (destructuring with useShallow):**

```typescript
import { useShallow } from 'zustand/react/shallow'

function BearStats() {
  // Shallow comparison prevents re-renders when other state changes
  const { bears, honey } = useBearStore(
    useShallow((state) => ({ bears: state.bears, honey: state.honey }))
  )
  return <div>Bears: {bears}, Honey: {honey}</div>
}
```

**Benefits:**
- Components only re-render when selected state changes
- More predictable performance
- Easier to optimize specific components

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
