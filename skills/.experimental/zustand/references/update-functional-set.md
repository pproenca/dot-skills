---
title: Use Functional Form When Updating Based on Previous State
impact: MEDIUM-HIGH
impactDescription: prevents stale state bugs
tags: update, functional, setState, closures
---

## Use Functional Form When Updating Based on Previous State

When updating state based on its current value, use the functional form of `set`. This ensures you always work with the latest state, avoiding stale closure bugs.

**Incorrect (uses stale closure):**

```typescript
const useCounterStore = create<CounterState>((set, get) => ({
  count: 0,

  // Captures `count` in closure, may be stale
  incrementBy: (amount) => set({ count: get().count + amount }),

  // Multiple rapid calls may lose updates
  incrementTwice: () => {
    set({ count: get().count + 1 })
    set({ count: get().count + 1 })
    // May result in +1 instead of +2
  },
}))
```

**Correct (functional updater):**

```typescript
const useCounterStore = create<CounterState>((set) => ({
  count: 0,

  // Always uses latest state
  incrementBy: (amount) => set((state) => ({ count: state.count + amount })),

  // Both updates apply correctly
  incrementTwice: () => {
    set((state) => ({ count: state.count + 1 }))
    set((state) => ({ count: state.count + 1 }))
    // Always results in +2
  },
}))
```

**When to use each approach:**

```typescript
const useStore = create<State>((set) => ({
  user: null,
  count: 0,

  // Direct set: when not depending on previous state
  setUser: (user) => set({ user }),

  // Functional set: when depending on previous state
  increment: () => set((state) => ({ count: state.count + 1 })),

  // Functional set: for conditional updates
  decrementIfPositive: () => set((state) =>
    state.count > 0 ? { count: state.count - 1 } : state
  ),
}))
```

Reference: [Zustand Documentation - Updating State](https://zustand.docs.pmnd.rs/guides/updating-state)
