---
title: Use StateCreator for Slice Typing
impact: LOW-MEDIUM
impactDescription: enables type-safe slices with cross-slice access
tags: ts, StateCreator, slices, typing
---

## Use StateCreator for Slice Typing

When using the slices pattern, use `StateCreator` type to properly type slice creators. This enables type-safe access to other slices and proper middleware typing.

**Incorrect (loses type inference):**

```typescript
// Types are lost or require manual casting
const createBearSlice = (set, get) => ({
  bears: 0,
  // get() returns unknown, no type safety
  eatFish: () => set({ bears: get().bears + 1 }),
})

const createFishSlice = (set, get) => ({
  fish: 10,
  // Can't access bears slice type-safely
  feedBear: () => set({ fish: get().fish - 1 }),
})
```

**Correct (typed with StateCreator):**

```typescript
import { create, StateCreator } from 'zustand'

interface BearSlice {
  bears: number
  addBear: () => void
  eatFish: () => void
}

interface FishSlice {
  fish: number
  addFish: () => void
}

type BoundStore = BearSlice & FishSlice

// StateCreator<FullStore, Middlewares, SliceMiddlewares, ThisSlice>
const createBearSlice: StateCreator<
  BoundStore,
  [],
  [],
  BearSlice
> = (set) => ({
  bears: 0,
  addBear: () => set((s) => ({ bears: s.bears + 1 })),
  // Type-safe access to fish slice
  eatFish: () => set((s) => ({
    bears: s.bears,
    fish: s.fish - 1,
  })),
})

const createFishSlice: StateCreator<
  BoundStore,
  [],
  [],
  FishSlice
> = (set) => ({
  fish: 10,
  addFish: () => set((s) => ({ fish: s.fish + 1 })),
})

const useBoundStore = create<BoundStore>()((...a) => ({
  ...createBearSlice(...a),
  ...createFishSlice(...a),
}))
```

**StateCreator type parameters:**
1. Full store type (all slices combined)
2. Middleware types applied to store
3. Middleware types applied to this slice
4. This slice's type

Reference: [Zustand - TypeScript Guide](https://zustand.docs.pmnd.rs/guides/advanced-typescript)
