---
title: Type Selectors for Reusability
impact: LOW-MEDIUM
impactDescription: enables type-safe selector composition
tags: ts, selectors, generics, typing
---

## Type Selectors for Reusability

Create typed selector factories and utilities for consistent, reusable selection patterns across your codebase.

**Incorrect (untyped inline selectors):**

```typescript
// Each usage might have different typing
const bears = useStore((s) => s.bears)  // s is inferred
const fish = useStore((s) => s.fish)    // repeated pattern

// No shared selector logic
const totalAnimals = useStore((s) => s.bears + s.fish)
```

**Correct (typed selector utilities):**

```typescript
import { StoreApi, UseBoundStore } from 'zustand'

// Selector type
type Selector<S, R> = (state: S) => R

// Create typed selector function
function createSelector<S, R>(selector: Selector<S, R>): Selector<S, R> {
  return selector
}

// Define selectors outside components
const selectBears = createSelector<BearStore, number>((s) => s.bears)
const selectFish = createSelector<BearStore, number>((s) => s.fish)
const selectTotalAnimals = createSelector<BearStore, number>(
  (s) => s.bears + s.fish
)

// Usage
function BearCounter() {
  const bears = useBearStore(selectBears)
  const total = useBearStore(selectTotalAnimals)
  return <div>{bears} of {total} animals</div>
}
```

**Alternative (selector factory with auto-generated hooks):**

```typescript
type CreateBoundSelector<S> = <R>(selector: (state: S) => R) => () => R

function createBoundSelectors<S>(
  useStore: UseBoundStore<StoreApi<S>>
): CreateBoundSelector<S> {
  return (selector) => () => useStore(selector)
}

const useBearStore = create<BearStore>()((set) => ({
  bears: 0,
  fish: 10,
  addBear: () => set((s) => ({ bears: s.bears + 1 })),
}))

const createSelector = createBoundSelectors(useBearStore)

// Type-safe selector hooks
const useBears = createSelector((s) => s.bears)
const useFish = createSelector((s) => s.fish)
const useTotal = createSelector((s) => s.bears + s.fish)

// Usage
function Stats() {
  const total = useTotal()
  return <span>Total: {total}</span>
}
```

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
