---
title: Name Actions for DevTools Debugging
impact: MEDIUM
impactDescription: enables time-travel debugging, improves traceability
tags: mw, devtools, debugging, action-names
---

## Name Actions for DevTools Debugging

When using the devtools middleware, provide action names as the third argument to `set`. This enables meaningful action labels in Redux DevTools for easier debugging.

**Incorrect (unnamed actions):**

```typescript
import { devtools } from 'zustand/middleware'

const useBearStore = create<BearState>()(
  devtools((set) => ({
    bears: 0,
    honey: 100,

    // Actions appear as "anonymous" in DevTools
    increasePopulation: () => set((s) => ({ bears: s.bears + 1 })),
    eatHoney: () => set((s) => ({ honey: s.honey - 10 })),
  }))
)
// DevTools shows: "anonymous", "anonymous" - hard to trace
```

**Correct (named actions):**

```typescript
import { devtools } from 'zustand/middleware'

const useBearStore = create<BearState>()(
  devtools((set) => ({
    bears: 0,
    honey: 100,

    increasePopulation: () =>
      set(
        (s) => ({ bears: s.bears + 1 }),
        undefined,               // replace flag (false = merge)
        'bears/increasePopulation' // action name
      ),

    eatHoney: () =>
      set(
        (s) => ({ honey: s.honey - 10 }),
        undefined,
        'bears/eatHoney'
      ),
  }))
)
// DevTools shows: "bears/increasePopulation", "bears/eatHoney"
```

**Alternative (slices with namespaced actions):**

```typescript
const createBearSlice: StateCreator<
  BearStore,
  [['zustand/devtools', never]],
  [],
  BearSlice
> = (set) => ({
  bears: 0,
  addBear: () =>
    set(
      (s) => ({ bears: s.bears + 1 }),
      undefined,
      'bear/addBear'
    ),
})

const createFishSlice: StateCreator<
  BearStore,
  [['zustand/devtools', never]],
  [],
  FishSlice
> = (set) => ({
  fish: 0,
  addFish: () =>
    set(
      (s) => ({ fish: s.fish + 1 }),
      undefined,
      'fish/addFish'
    ),
})
```

**Benefits:**
- Clear action history in DevTools
- Time-travel debugging becomes useful
- Easier to trace state changes in complex apps

Reference: [Zustand - Devtools Middleware](https://zustand.docs.pmnd.rs/middlewares/devtools)
