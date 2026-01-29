---
title: Preserve Type Inference with Middleware
impact: LOW-MEDIUM
impactDescription: maintains autocomplete and type checking
tags: ts, middleware, inference, typing
---

## Preserve Type Inference with Middleware

When combining middlewares, TypeScript inference can break. Use the double-parentheses pattern `create<State>()()` and explicitly type StateCreator for slices with middleware.

**Incorrect (loses inference with middlewares):**

```typescript
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'

// Type error or loses inference
const useStore = create<State>(
  devtools(
    persist(
      (set) => ({
        count: 0,
        // set might be typed as 'any'
        increment: () => set((s) => ({ count: s.count + 1 })),
      }),
      { name: 'store' }
    )
  )
)
```

**Correct (double parentheses pattern):**

```typescript
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'

interface State {
  count: number
  increment: () => void
}

// Double parentheses enables proper inference
const useStore = create<State>()(
  devtools(
    persist(
      (set) => ({
        count: 0,
        increment: () => set((s) => ({ count: s.count + 1 })),
      }),
      { name: 'store' }
    )
  )
)
```

**With slices and middleware:**

```typescript
import { StateCreator } from 'zustand'
import { devtools } from 'zustand/middleware'

interface BearSlice {
  bears: number
  addBear: () => void
}

// Specify devtools in middleware array
const createBearSlice: StateCreator<
  BearSlice,
  [['zustand/devtools', never]],  // Middleware this slice expects
  [],
  BearSlice
> = (set) => ({
  bears: 0,
  addBear: () => set(
    (s) => ({ bears: s.bears + 1 }),
    undefined,
    'bears/addBear'  // Action name for devtools
  ),
})

const useBearStore = create<BearSlice>()(
  devtools(createBearSlice)
)
```

Reference: [Zustand - TypeScript Guide](https://zustand.docs.pmnd.rs/guides/advanced-typescript)
