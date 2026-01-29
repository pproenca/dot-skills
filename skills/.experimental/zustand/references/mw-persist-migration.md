---
title: Version and Migrate Persisted State
impact: MEDIUM
impactDescription: prevents breaking changes when state shape evolves
tags: mw, persist, migration, versioning
---

## Version and Migrate Persisted State

When your state shape changes, users with old persisted data will have issues. Use `version` and `migrate` to transform old state to the new shape.

**Incorrect (no versioning, breaks on schema change):**

```typescript
// Version 1: Original schema
const useUserStore = create<UserState>()(
  persist(
    (set) => ({
      username: '',           // Renamed to 'name' in v2
      email: '',
    }),
    { name: 'user-storage' }
  )
)

// Later, you rename username to name:
// Old persisted data: { username: 'john' }
// New schema expects: { name: 'john' }
// Result: name is undefined, username ignored
```

**Correct (versioned with migration):**

```typescript
import { persist } from 'zustand/middleware'

interface UserStateV2 {
  name: string        // Renamed from username
  email: string
  preferences: {      // New in v2
    theme: string
  }
}

const useUserStore = create<UserStateV2>()(
  persist(
    (set) => ({
      name: '',
      email: '',
      preferences: { theme: 'light' },
    }),
    {
      name: 'user-storage',
      version: 2,
      migrate: (persisted: unknown, version: number) => {
        const state = persisted as Record<string, unknown>

        if (version === 0 || version === 1) {
          // Migrate from v1 to v2
          return {
            name: state.username || state.name || '',
            email: state.email || '',
            preferences: state.preferences || { theme: 'light' },
          }
        }

        return state as UserStateV2
      },
    }
  )
)
```

**Alternative (multi-step migrations):**

```typescript
const migrations: Record<number, (state: unknown) => unknown> = {
  1: (state: any) => ({
    ...state,
    name: state.username,
    username: undefined,
  }),
  2: (state: any) => ({
    ...state,
    preferences: state.preferences || { theme: 'light' },
  }),
}

const useUserStore = create<UserState>()(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'user-storage',
      version: 2,
      migrate: (persisted, version) => {
        let state = persisted
        for (let v = version; v < 2; v++) {
          state = migrations[v + 1]?.(state) || state
        }
        return state as UserState
      },
    }
  )
)
```

Reference: [Zustand - Persist Middleware](https://zustand.docs.pmnd.rs/middlewares/persist)
