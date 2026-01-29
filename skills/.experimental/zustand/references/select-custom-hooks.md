---
title: Export Custom Hooks Not Raw Store
impact: CRITICAL
impactDescription: prevents accidental full-store subscriptions
tags: select, hooks, api-design, encapsulation
---

## Export Custom Hooks Not Raw Store

Wrap store access in custom hooks instead of exporting the raw store. This prevents accidental subscriptions to the entire store and provides a cleaner, more maintainable API.

**Incorrect (exports raw store):**

```typescript
// store.ts
export const useBearStore = create<BearState>((set) => ({
  bears: 0,
  fish: 10,
  honey: 100,
  increasePopulation: () => set((s) => ({ bears: s.bears + 1 })),
  eatFish: () => set((s) => ({ fish: s.fish - 1 })),
}))

// component.tsx
import { useBearStore } from './store'

function BearCounter() {
  // Easy to forget selector, subscribes to everything
  const { bears } = useBearStore()
  return <div>{bears}</div>
}
```

**Correct (exports custom hooks):**

```typescript
// store.ts
const useBearStore = create<BearState>((set) => ({
  bears: 0,
  fish: 10,
  honey: 100,
  actions: {
    increasePopulation: () => set((s) => ({ bears: s.bears + 1 })),
    eatFish: () => set((s) => ({ fish: s.fish - 1 })),
  },
}))

// Export only custom hooks
export const useBears = () => useBearStore((s) => s.bears)
export const useFish = () => useBearStore((s) => s.fish)
export const useHoney = () => useBearStore((s) => s.honey)
export const useBearActions = () => useBearStore((s) => s.actions)

// component.tsx
import { useBears, useBearActions } from './store'

function BearCounter() {
  // Cannot accidentally subscribe to entire store
  const bears = useBears()
  const { increasePopulation } = useBearActions()
  return <button onClick={increasePopulation}>{bears}</button>
}
```

**Benefits:**
- Impossible to accidentally subscribe to entire store
- Selectors defined once, reused everywhere
- Easy to add memoization or logging later
- Store implementation is encapsulated

Reference: [Working with Zustand - TkDodo](https://tkdodo.eu/blog/working-with-zustand)
