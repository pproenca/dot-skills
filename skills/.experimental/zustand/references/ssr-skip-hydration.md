---
title: Use skipHydration in SSR Contexts
impact: MEDIUM
impactDescription: prevents hydration mismatch errors
tags: ssr, hydration, nextjs, server-rendering
---

## Use skipHydration in SSR Contexts

In SSR environments like Next.js, persisted stores can cause hydration mismatches because the server renders with initial state while the client hydrates with persisted state. Use `skipHydration: true` to defer hydration.

**Incorrect (automatic hydration causes mismatch):**

```typescript
import { persist } from 'zustand/middleware'

const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    { name: 'theme-storage' }
  )
)

// Server renders: theme='light'
// Client hydrates with localStorage: theme='dark'
// Error: "Text content does not match server-rendered HTML"
```

**Correct (skip automatic hydration):**

```typescript
import { persist } from 'zustand/middleware'

const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'theme-storage',
      skipHydration: true, // Disable automatic hydration
    }
  )
)

// Manually trigger hydration after client mount
// See ssr-manual-rehydrate rule
```

**When to use:**
- Any persisted store in Next.js/Remix/SSR apps
- Stores that affect server-rendered content
- Stores where initial state differs from persisted state

**When NOT needed:**
- Client-only apps (CRA, Vite without SSR)
- Stores that don't use persist middleware
- Persisted values not rendered on initial page load

Reference: [Zustand - Persist Middleware](https://zustand.docs.pmnd.rs/middlewares/persist)
