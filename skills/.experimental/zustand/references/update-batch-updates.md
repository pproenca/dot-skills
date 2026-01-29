---
title: Batch Related Updates in Single set Call
impact: MEDIUM
impactDescription: reduces re-renders, ensures consistent state
tags: update, batching, performance, consistency
---

## Batch Related Updates in Single set Call

When multiple state properties need to change together, update them in a single `set` call. This ensures state consistency and triggers only one re-render.

**Incorrect (multiple set calls):**

```typescript
const useFormStore = create<FormState>((set) => ({
  values: {},
  errors: {},
  touched: {},
  isSubmitting: false,

  submitForm: async () => {
    set({ isSubmitting: true })          // Re-render 1
    set({ errors: {} })                   // Re-render 2

    try {
      await submitToServer(get().values)
      set({ isSubmitting: false })        // Re-render 3
    } catch (error) {
      set({ errors: parseErrors(error) }) // Re-render 4
      set({ isSubmitting: false })        // Re-render 5
    }
  },
}))
```

**Correct (batched updates):**

```typescript
const useFormStore = create<FormState>((set, get) => ({
  values: {},
  errors: {},
  touched: {},
  isSubmitting: false,

  submitForm: async () => {
    // Single update for start
    set({ isSubmitting: true, errors: {} })

    try {
      await submitToServer(get().values)
      // Single update for success
      set({ isSubmitting: false })
    } catch (error) {
      // Single update for failure
      set({
        errors: parseErrors(error),
        isSubmitting: false,
      })
    }
  },
}))
```

**Note on React 18:** React 18 batches state updates automatically within event handlers and effects. However, batching in Zustand still matters for:
- State consistency within a single synchronous operation
- Reducing subscriber notifications
- Clear intent in code

**When separate calls are acceptable:**

```typescript
// Separate updates when they're truly independent
set({ count: state.count + 1 })
// ... some async work
set({ lastUpdated: Date.now() })
```

Reference: [Zustand Documentation](https://zustand.docs.pmnd.rs/)
