---
title: Never Mutate State Directly
impact: CRITICAL
impactDescription: prevents silent state bugs and missed re-renders
tags: update, immutability, mutations, correctness
---

## Never Mutate State Directly

Always create new objects/arrays when updating state. Direct mutation bypasses Zustand's change detection, causing components to not re-render and DevTools to miss updates.

**Incorrect (mutates existing state):**

```typescript
const useListStore = create<ListState>((set, get) => ({
  items: [],

  addItem: (item) => {
    // Mutates existing array
    get().items.push(item)
    set({ items: get().items })
    // Same array reference, components may not re-render
  },

  updateItem: (id, updates) => {
    const items = get().items
    const item = items.find((i) => i.id === id)
    // Mutates existing object
    Object.assign(item, updates)
    set({ items })
  },
}))
```

**Correct (creates new references):**

```typescript
const useListStore = create<ListState>((set) => ({
  items: [],

  addItem: (item) => set((state) => ({
    items: [...state.items, item], // New reference, triggers re-render
  })),

  updateItem: (id, updates) => set((state) => ({
    items: state.items.map((item) =>
      item.id === id ? { ...item, ...updates } : item
    ),
  })),

  removeItem: (id) => set((state) => ({
    items: state.items.filter((item) => item.id !== id),
  })),
}))
```

**Alternative (use immer for complex updates):**

```typescript
import { immer } from 'zustand/middleware/immer'

const useListStore = create<ListState>()(
  immer((set) => ({
    items: [],

    // Immer allows mutation syntax, handles immutability internally
    addItem: (item) => set((state) => {
      state.items.push(item)
    }),

    updateItem: (id, updates) => set((state) => {
      const item = state.items.find((i) => i.id === id)
      if (item) Object.assign(item, updates)
    }),
  }))
)
```

Reference: [Zustand - Immer Middleware](https://zustand.docs.pmnd.rs/integrations/immer-middleware)
