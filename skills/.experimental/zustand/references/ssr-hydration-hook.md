---
title: Use Custom Hook to Prevent Hydration Mismatch
impact: MEDIUM
impactDescription: prevents hydration mismatch errors
tags: ssr, hooks, hydration, mismatch
---

## Use Custom Hook to Prevent Hydration Mismatch

Create a custom hook that delays returning the store value until after hydration. This ensures components render with initial state during SSR and hydration, then update with persisted state.

**Incorrect (direct store access causes mismatch):**

```typescript
function ThemeSwitcher() {
  // On server: 'light' (initial)
  // On client during hydration: 'dark' (from localStorage)
  // Mismatch error!
  const theme = useThemeStore((s) => s.theme)

  return <span>Current theme: {theme}</span>
}
```

**Correct (delayed hydration hook):**

```typescript
// hooks/useHydratedStore.ts
import { useState, useEffect } from 'react'

export function useHydratedStore<T, F>(
  store: (callback: (state: T) => F) => F,
  selector: (state: T) => F
): F | undefined {
  const storeValue = store(selector)
  const [hydrated, setHydrated] = useState(false)

  useEffect(() => {
    setHydrated(true)
  }, [])

  // Return undefined during SSR and initial hydration
  // Return actual value after client mount
  return hydrated ? storeValue : undefined
}

// Usage
function ThemeSwitcher() {
  const theme = useHydratedStore(useThemeStore, (s) => s.theme)

  // Render fallback during hydration
  if (theme === undefined) {
    return <span>Loading theme...</span>
  }

  return <span>Current theme: {theme}</span>
}
```

**Alternative (return initial value during SSR):**

```typescript
export function useHydratedStore<T, F>(
  store: (callback: (state: T) => F) => F,
  selector: (state: T) => F,
  initialValue: F
): F {
  const storeValue = store(selector)
  const [hydrated, setHydrated] = useState(false)

  useEffect(() => {
    setHydrated(true)
  }, [])

  return hydrated ? storeValue : initialValue
}

// Usage - provides consistent initial value
function ThemeSwitcher() {
  const theme = useHydratedStore(useThemeStore, (s) => s.theme, 'light')
  // Always renders 'light' on server and during hydration
  return <span>Current theme: {theme}</span>
}
```

Reference: [Zustand - Persisting Store Data](https://github.com/pmndrs/zustand/blob/main/docs/integrations/persisting-store-data.md)
