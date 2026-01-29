---
title: Use Auto-Generated Selectors for Large Stores
impact: HIGH
impactDescription: reduces boilerplate, ensures consistent patterns
tags: select, auto-generate, utility, typescript
---

## Use Auto-Generated Selectors for Large Stores

For stores with many properties, writing individual selector hooks is tedious. Use a utility to auto-generate selectors for each property.

**Incorrect (manual selectors for each property):**

```typescript
const useSettingsStore = create<SettingsState>((set) => ({
  theme: 'light',
  language: 'en',
  notifications: true,
  fontSize: 14,
  autoSave: true,
  // ... 20 more settings
}))

// Tedious to write for each property
export const useTheme = () => useSettingsStore((s) => s.theme)
export const useLanguage = () => useSettingsStore((s) => s.language)
export const useNotifications = () => useSettingsStore((s) => s.notifications)
// ... 20 more hooks
```

**Correct (auto-generate selectors):**

```typescript
import { StoreApi, UseBoundStore } from 'zustand'

type WithSelectors<S> = S extends { getState: () => infer T }
  ? S & { use: { [K in keyof T]: () => T[K] } }
  : never

const createSelectors = <S extends UseBoundStore<StoreApi<object>>>(
  store: S
) => {
  const storeIn = store as WithSelectors<typeof store>
  storeIn.use = {}
  for (const key of Object.keys(storeIn.getState())) {
    (storeIn.use as Record<string, () => unknown>)[key] = () =>
      storeIn((s) => s[key as keyof typeof s])
  }
  return storeIn
}

// Create store with auto-generated selectors
const useSettingsStoreBase = create<SettingsState>((set) => ({
  theme: 'light',
  language: 'en',
  notifications: true,
  fontSize: 14,
  autoSave: true,
}))

export const useSettingsStore = createSelectors(useSettingsStoreBase)

// Usage - type-safe auto-generated hooks
const theme = useSettingsStore.use.theme()
const language = useSettingsStore.use.language()
```

**Benefits:**
- No manual selector boilerplate
- Type-safe generated hooks
- Consistent patterns across the codebase

Reference: [Zustand - Auto Generating Selectors](https://zustand.docs.pmnd.rs/guides/auto-generating-selectors)
