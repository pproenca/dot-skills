---
title: Manually Rehydrate on Client Mount
impact: MEDIUM
impactDescription: prevents hydration errors in SSR apps
tags: ssr, hydration, rehydrate, useEffect
---

## Manually Rehydrate on Client Mount

After disabling automatic hydration with `skipHydration`, trigger rehydration manually in a `useEffect` after the component mounts. This ensures server and client render the same initial content.

**Incorrect (no manual rehydration):**

```typescript
const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'theme-storage',
      skipHydration: true,
    }
  )
)

// Store never loads persisted state
// User always sees 'light' theme on page load
```

**Correct (manual rehydration in layout/app):**

```typescript
// stores/theme.ts
const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'theme-storage',
      skipHydration: true,
    }
  )
)

// app/layout.tsx or _app.tsx
'use client'

import { useEffect } from 'react'
import { useThemeStore } from '@/stores/theme'

function HydrationProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // Rehydrate after client mount
    useThemeStore.persist.rehydrate()
  }, [])

  return <>{children}</>
}
```

**Alternative (rehydrate multiple stores):**

```typescript
'use client'

import { useEffect } from 'react'
import { useThemeStore } from '@/stores/theme'
import { useSettingsStore } from '@/stores/settings'
import { useUserStore } from '@/stores/user'

export function StoreHydration() {
  useEffect(() => {
    // Rehydrate all persisted stores
    useThemeStore.persist.rehydrate()
    useSettingsStore.persist.rehydrate()
    useUserStore.persist.rehydrate()
  }, [])

  return null
}

// In layout
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <StoreHydration />
        {children}
      </body>
    </html>
  )
}
```

Reference: [Zustand - Persist Middleware](https://zustand.docs.pmnd.rs/middlewares/persist)
