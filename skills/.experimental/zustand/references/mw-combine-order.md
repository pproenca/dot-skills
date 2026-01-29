---
title: Apply Middlewares in Correct Order
impact: MEDIUM
impactDescription: prevents DevTools state invisibility
tags: mw, middleware, order, composition
---

## Apply Middlewares in Correct Order

Middleware order matters. Each middleware wraps the next, so the outermost middleware processes state changes first. Follow this order: devtools (outer) → persist → immer (inner).

**Incorrect (wrong order breaks devtools):**

```typescript
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'

const useStore = create<State>()(
  // Wrong: persist outside devtools won't show persisted state in DevTools
  persist(
    devtools(
      immer((set) => ({
        count: 0,
        increment: () => set((s) => { s.count++ }),
      }))
    ),
    { name: 'store' }
  )
)
```

**Correct (proper middleware order):**

```typescript
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'

const useStore = create<State>()(
  // Correct order: devtools → persist → immer
  devtools(
    persist(
      immer((set) => ({
        count: 0,
        increment: () => set((s) => { s.count++ }),
      })),
      { name: 'store' }
    ),
    { name: 'store', enabled: process.env.NODE_ENV === 'development' }
  )
)
```

**Recommended middleware order:**

```text
1. devtools (outermost) - sees all state changes for debugging
2. subscribeWithSelector - adds selective subscriptions
3. persist - saves/restores state
4. immer (innermost) - transforms mutations to immutable updates
```

**Why this order:**
- `devtools` should see final state changes, so it wraps everything
- `persist` should save the immer-processed state, not raw mutations
- `immer` is innermost because it transforms how `set` works

Reference: [Zustand Documentation - Middlewares](https://zustand.docs.pmnd.rs/middlewares/devtools)
