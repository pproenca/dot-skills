---
title: Understand set() Shallow Merge Behavior
impact: MEDIUM-HIGH
impactDescription: prevents accidental state overwrites
tags: update, merge, shallow, set
---

## Understand set() Shallow Merge Behavior

Zustand's `set` performs a shallow merge by default. It merges top-level properties but replaces nested objects entirely. Understand this to avoid accidental data loss.

**Incorrect (expects deep merge):**

```typescript
const useUserStore = create<UserState>((set) => ({
  user: {
    name: 'John',
    email: 'john@example.com',
    preferences: {
      theme: 'dark',
      notifications: true,
    },
  },

  // Expects to only update theme, but replaces entire preferences
  updateTheme: (theme) => set({
    user: {
      preferences: { theme },
    },
  }),
  // Result: user = { preferences: { theme: 'light' } }
  // name, email, and notifications are lost!
}))
```

**Correct (preserve nested structure):**

```typescript
const useUserStore = create<UserState>((set) => ({
  user: {
    name: 'John',
    email: 'john@example.com',
    preferences: {
      theme: 'dark',
      notifications: true,
    },
  },

  // Spread to preserve existing properties at each level
  updateTheme: (theme) => set((state) => ({
    user: {
      ...state.user,
      preferences: {
        ...state.user.preferences,
        theme,
      },
    },
  })),
}))
```

**Alternative (flatten state structure):**

```typescript
// Flatter state is easier to update
const useUserStore = create<UserState>((set) => ({
  userName: 'John',
  userEmail: 'john@example.com',
  prefTheme: 'dark',
  prefNotifications: true,

  // Simple top-level updates
  updateTheme: (prefTheme) => set({ prefTheme }),
}))
```

**Alternative (use immer for deep updates):**

```typescript
import { immer } from 'zustand/middleware/immer'

const useUserStore = create<UserState>()(
  immer((set) => ({
    user: { name: 'John', preferences: { theme: 'dark' } },

    updateTheme: (theme) => set((state) => {
      state.user.preferences.theme = theme
    }),
  }))
)
```

Reference: [Zustand Documentation - Updating State](https://zustand.docs.pmnd.rs/guides/updating-state)
