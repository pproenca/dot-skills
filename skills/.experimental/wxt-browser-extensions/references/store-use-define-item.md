---
title: Use storage.defineItem for Type-Safe Access
impact: HIGH
impactDescription: prevents null reference errors and type mismatches
tags: store, defineItem, type-safe, fallback
---

## Use storage.defineItem for Type-Safe Access

Use `storage.defineItem` to define typed storage items with fallback values. This prevents null checks scattered throughout your code and catches type errors at build time.

**Incorrect (raw getItem with manual typing):**

```typescript
// Scattered null checks, no type safety
async function getSettings() {
  const settings = await storage.getItem<Settings>('local:settings')
  if (!settings) {
    return { theme: 'light', notifications: true }
  }
  return settings
}

async function updateTheme(theme: string) {
  const settings = await storage.getItem<Settings>('local:settings')
  await storage.setItem('local:settings', { ...settings, theme })
}
```

**Correct (defineItem with fallback):**

```typescript
// utils/storage.ts
interface Settings {
  theme: 'light' | 'dark'
  notifications: boolean
  volume: number
}

export const settings = storage.defineItem<Settings>('local:settings', {
  fallback: { theme: 'light', notifications: true, volume: 80 }
})

// Usage - no null checks needed
async function getSettings() {
  return await settings.getValue() // Always returns Settings, never null
}

async function updateTheme(theme: 'light' | 'dark') {
  const current = await settings.getValue()
  await settings.setValue({ ...current, theme })
}

// Watch for changes
settings.watch((newSettings) => {
  applySettings(newSettings) // TypeScript knows this is Settings
})
```

**When NOT to use this pattern:**
- Dynamic keys that cannot be known at compile time
- One-time migration scripts that access legacy storage formats
- Reading storage items created by other extensions

**`fallback` vs `init`:**
- `fallback` — in-memory default returned when storage is empty. Value is NOT persisted.
- `init` — one-time initializer that saves the value to storage on first access. Use for unique IDs, install dates, etc.

```typescript
// fallback: returns 'dark' but doesn't save to storage
const theme = storage.defineItem('local:theme', { fallback: 'dark' })

// init: generates UUID and saves to storage on first access
const installId = storage.defineItem('local:installId', {
  init: () => crypto.randomUUID()
})
```

Omit both when `null` is a valid state. See [`store-versioned-migrations`](store-versioned-migrations.md) for evolving storage schemas over time.

Reference: [WXT Storage defineItem](https://wxt.dev/storage)
