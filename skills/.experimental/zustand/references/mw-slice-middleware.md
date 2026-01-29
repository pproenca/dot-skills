---
title: Apply Middleware at Combined Store Level
impact: MEDIUM
impactDescription: prevents middleware conflicts and state bugs
tags: mw, slices, middleware, architecture
---

## Apply Middleware at Combined Store Level

When using the slices pattern, apply middleware to the combined store, not individual slices. This ensures middleware works consistently across all slices.

**Incorrect (middleware on individual slices):**

```typescript
import { devtools, persist } from 'zustand/middleware'

// Wrong: applying middleware to slice
const createBearSlice = (set) =>
  devtools((innerSet) => ({
    bears: 0,
    addBear: () => innerSet((s) => ({ bears: s.bears + 1 })),
  }))(set)

const createFishSlice = (set) =>
  persist((innerSet) => ({
    fish: 0,
    addFish: () => innerSet((s) => ({ fish: s.fish + 1 })),
  }), { name: 'fish' })(set)

// Middleware behavior is inconsistent and may conflict
```

**Correct (middleware at combined store level):**

```typescript
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'

// Slices are plain state creators
const createBearSlice = (set, get) => ({
  bears: 0,
  addBear: () => set((s) => ({ bears: s.bears + 1 })),
})

const createFishSlice = (set, get) => ({
  fish: 0,
  addFish: () => set((s) => ({ fish: s.fish + 1 })),
})

// Apply middleware when combining
const useBoundStore = create(
  devtools(
    persist(
      (...args) => ({
        ...createBearSlice(...args),
        ...createFishSlice(...args),
      }),
      {
        name: 'bound-store',
        partialize: (state) => ({
          bears: state.bears,
          fish: state.fish,
        }),
      }
    ),
    { name: 'BoundStore' }
  )
)
```

**TypeScript version with proper typing:**

```typescript
import { StateCreator } from 'zustand'

interface BearSlice {
  bears: number
  addBear: () => void
}

interface FishSlice {
  fish: number
  addFish: () => void
}

type BoundStore = BearSlice & FishSlice

const createBearSlice: StateCreator<BoundStore, [], [], BearSlice> = (set) => ({
  bears: 0,
  addBear: () => set((s) => ({ bears: s.bears + 1 })),
})

const createFishSlice: StateCreator<BoundStore, [], [], FishSlice> = (set) => ({
  fish: 0,
  addFish: () => set((s) => ({ fish: s.fish + 1 })),
})
```

Reference: [Zustand - Slices Pattern](https://zustand.docs.pmnd.rs/guides/slices-pattern)
