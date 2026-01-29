---
title: Type Combined Stores Correctly
impact: LOW-MEDIUM
impactDescription: prevents cross-slice type errors at compile time
tags: ts, slices, combined-store, typing
---

## Type Combined Stores Correctly

When combining slices, ensure the combined store type includes all slices and properly types cross-slice interactions.

**Incorrect (incomplete combined type):**

```typescript
// Missing slice in combined type
const useBoundStore = create<BearSlice & FishSlice>()((...a) => ({
  ...createBearSlice(...a),
  ...createFishSlice(...a),
  ...createSharedSlice(...a), // SharedSlice not in type!
}))

// SharedSlice actions won't be typed correctly
const { addBoth } = useBoundStore() // Type error
```

**Correct (complete combined type):**

```typescript
import { create, StateCreator } from 'zustand'

interface BearSlice {
  bears: number
  addBear: () => void
}

interface FishSlice {
  fish: number
  addFish: () => void
}

interface SharedSlice {
  addBoth: () => void
  getTotalAnimals: () => number
}

// Complete combined type
type BoundStore = BearSlice & FishSlice & SharedSlice

const createBearSlice: StateCreator<BoundStore, [], [], BearSlice> = (set) => ({
  bears: 0,
  addBear: () => set((s) => ({ bears: s.bears + 1 })),
})

const createFishSlice: StateCreator<BoundStore, [], [], FishSlice> = (set) => ({
  fish: 0,
  addFish: () => set((s) => ({ fish: s.fish + 1 })),
})

// SharedSlice can access all other slices type-safely
const createSharedSlice: StateCreator<BoundStore, [], [], SharedSlice> = (
  set,
  get
) => ({
  addBoth: () => {
    get().addBear()
    get().addFish()
  },
  getTotalAnimals: () => get().bears + get().fish,
})

// Properly typed combined store
const useBoundStore = create<BoundStore>()((...a) => ({
  ...createBearSlice(...a),
  ...createFishSlice(...a),
  ...createSharedSlice(...a),
}))

// All methods are properly typed
const { bears, fish, addBoth, getTotalAnimals } = useBoundStore()
```

**Benefits:**
- Cross-slice method calls are type-checked
- IDE autocomplete works across all slices
- Compile-time errors catch missing slice implementations

Reference: [Zustand - TypeScript Guide](https://zustand.docs.pmnd.rs/guides/advanced-typescript)
