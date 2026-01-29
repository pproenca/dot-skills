---
title: Separate State and Actions Interfaces
impact: LOW-MEDIUM
impactDescription: improves code organization, enables type reuse
tags: ts, interfaces, organization, typing
---

## Separate State and Actions Interfaces

Define separate interfaces for state properties and actions. This improves readability, enables type reuse, and makes it easier to use `partialize` with persist.

**Incorrect (mixed state and actions):**

```typescript
// Hard to separate what's state vs actions
interface BearStore {
  bears: number
  fish: number
  honey: number
  isHibernating: boolean
  addBear: () => void
  removeBear: () => void
  eatFish: () => void
  eatHoney: (amount: number) => void
  startHibernation: () => void
  endHibernation: () => void
}

// Can't easily partialize just state
persist(storeCreator, {
  partialize: (state) => ({
    bears: state.bears,
    fish: state.fish,
    // Must list each property manually
  }),
})
```

**Correct (separated interfaces):**

```typescript
// State properties
interface BearState {
  bears: number
  fish: number
  honey: number
  isHibernating: boolean
}

// Actions
interface BearActions {
  addBear: () => void
  removeBear: () => void
  eatFish: () => void
  eatHoney: (amount: number) => void
  startHibernation: () => void
  endHibernation: () => void
}

// Combined store type
type BearStore = BearState & BearActions

// Now partialize is simple
persist(storeCreator, {
  partialize: (state): BearState => ({
    bears: state.bears,
    fish: state.fish,
    honey: state.honey,
    isHibernating: state.isHibernating,
  }),
})
```

**Alternative (with utility type for actions exclusion):**

```typescript
interface BearState {
  bears: number
  fish: number
}

interface BearActions {
  addBear: () => void
  eatFish: () => void
}

type BearStore = BearState & { actions: BearActions }

// Actions in namespace, easy to partialize
const useBearStore = create<BearStore>()(
  persist(
    (set) => ({
      bears: 0,
      fish: 10,
      actions: {
        addBear: () => set((s) => ({ bears: s.bears + 1 })),
        eatFish: () => set((s) => ({ fish: s.fish - 1 })),
      },
    }),
    {
      name: 'bear-store',
      // Exclude actions from persistence automatically
      partialize: ({ actions, ...state }) => state,
    }
  )
)
```

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
