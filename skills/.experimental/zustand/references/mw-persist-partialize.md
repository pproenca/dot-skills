---
title: Use partialize for Selective Persistence
impact: MEDIUM
impactDescription: reduces storage size, prevents sensitive data leaks
tags: mw, persist, partialize, storage
---

## Use partialize for Selective Persistence

Don't persist the entire store. Use `partialize` to select only the data that should survive page reloads. Exclude sensitive data, derived state, and temporary UI state.

**Incorrect (persists everything):**

```typescript
import { persist } from 'zustand/middleware'

const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,     // Sensitive, shouldn't persist long-term
      refreshToken: null,    // Sensitive
      isLoading: false,      // Transient UI state
      error: null,           // Transient
      loginAttempts: 0,      // Temporary

      login: (credentials) => { /* ... */ },
    }),
    { name: 'auth-storage' }
  )
)
// Persists loading state, errors, and sensitive tokens
```

**Correct (selective persistence):**

```typescript
import { persist } from 'zustand/middleware'

const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      isLoading: false,
      error: null,
      loginAttempts: 0,

      login: (credentials) => { /* ... */ },
    }),
    {
      name: 'auth-storage',
      // Only persist user profile, not tokens or UI state
      partialize: (state) => ({
        user: state.user,
      }),
    }
  )
)
```

**Alternative (exclude specific fields):**

```typescript
import { persist } from 'zustand/middleware'

const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      theme: 'dark',
      language: 'en',
      fontSize: 14,
      sidebarOpen: true,    // Don't persist
      modalOpen: false,     // Don't persist
    }),
    {
      name: 'settings-storage',
      partialize: (state) => {
        // Exclude transient UI state
        const { sidebarOpen, modalOpen, ...persisted } = state
        return persisted
      },
    }
  )
)
```

**What NOT to persist:**
- Loading/error states
- Sensitive tokens (use secure storage instead)
- Temporary UI state (modals, tooltips)
- Derived/computed values

Reference: [Zustand - Persist Middleware](https://zustand.docs.pmnd.rs/middlewares/persist)
