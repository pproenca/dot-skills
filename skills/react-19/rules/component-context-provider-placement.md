---
title: Place Context Providers Outside Client Boundaries
impact: MEDIUM
impactDescription: enables server rendering of provider trees
tags: component, context, providers, server-components
---

## Place Context Providers Outside Client Boundaries

Context providers can be Server Components if they don't use hooks. Keep providers that only pass data as Server Components to avoid unnecessary client JavaScript.

**Incorrect (all providers are client components):**

```tsx
// providers/theme-provider.tsx
'use client'

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  // No hooks, just passing a value
  return (
    <ThemeContext.Provider value={{ theme: 'light' }}>
      {children}
    </ThemeContext.Provider>
  )
}
// Unnecessary client component
```

**Correct (static provider as Server Component):**

```tsx
// providers/theme-provider.tsx
// No 'use client' - this can be a Server Component

import { ThemeContext } from './theme-context'

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const theme = getThemeFromCookie()  // Server-side

  return (
    <ThemeContext.Provider value={{ theme }}>
      {children}
    </ThemeContext.Provider>
  )
}
```

**When provider needs to be client:**

```tsx
// providers/auth-provider.tsx
'use client'  // Needed because of useState/useEffect

import { useState, useEffect } from 'react'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)

  useEffect(() => {
    // Subscribe to auth state
    return auth.onAuthStateChanged(setUser)
  }, [])

  return (
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  )
}
```

**Pattern for hybrid providers:**

```tsx
// Server Component provides initial data
async function DataProvider({ children }: { children: React.ReactNode }) {
  const initialData = await fetchInitialData()

  return (
    <ClientDataProvider initialData={initialData}>
      {children}
    </ClientDataProvider>
  )
}

// Client Component manages dynamic state
'use client'
function ClientDataProvider({ initialData, children }) {
  const [data, setData] = useState(initialData)
  // ...
}
```

Reference: [Context with Server Components](https://react.dev/reference/react/useContext#passing-data-deeply-into-the-tree)
