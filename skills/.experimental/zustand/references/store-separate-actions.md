---
title: Separate Actions from State in Dedicated Namespace
impact: CRITICAL
impactDescription: stable action references, cleaner component code
tags: store, actions, architecture, organization
---

## Separate Actions from State in Dedicated Namespace

Group all mutations into a dedicated `actions` namespace. This provides a single stable hook for all actions without re-render concerns, since actions never change after store creation.

**Incorrect (actions mixed with state):**

```typescript
const useBearStore = create<BearState>((set, get) => ({
  bears: 0,
  honey: 100,
  increasePopulation: () => set((s) => ({ bears: s.bears + 1 })),
  decreasePopulation: () => set((s) => ({ bears: s.bears - 1 })),
  eatHoney: () => set((s) => ({ honey: s.honey - 10 })),
  removeAllBears: () => set({ bears: 0 }),
}))

// Components must pick each action individually
const increase = useBearStore((s) => s.increasePopulation)
const decrease = useBearStore((s) => s.decreasePopulation)
```

**Correct (actions in dedicated namespace):**

```typescript
const useBearStore = create<BearState>((set, get) => ({
  bears: 0,
  honey: 100,
  actions: {
    increasePopulation: () => set((s) => ({ bears: s.bears + 1 })),
    decreasePopulation: () => set((s) => ({ bears: s.bears - 1 })),
    eatHoney: () => set((s) => ({ honey: s.honey - 10 })),
    removeAllBears: () => set({ bears: 0 }),
  },
}))

// Single hook for all actions, never causes re-renders
const useBearActions = () => useBearStore((s) => s.actions)

// Usage
const { increasePopulation, eatHoney } = useBearActions()
```

**Benefits:**
- Actions object is stable, never triggers re-renders
- Cleaner API with single actions hook
- Business logic stays in store, not components

Reference: [Working with Zustand - TkDodo](https://tkdodo.eu/blog/working-with-zustand)
