---
title: Deduplicated Warning Messages
impact: HIGH
impactDescription: prevents console spam when the same warning triggers repeatedly
tags: err, warnings, deduplication, Set
---

## Deduplicated Warning Messages

Use Set-based deduplication to prevent warning spam. The same warning should only appear once per session.

**Incorrect (repeated warnings):**

```typescript
function warn(message: string) {
  console.warn('Base UI: ' + message)
}

// Renders 100 items, logs 100 identical warnings
items.forEach(item => {
  if (item.invalid) {
    warn('Item is invalid')
  }
})
```

**Correct (deduplicated):**

```typescript
// utils/warn.ts
const printedWarnings = new Set<string>()

export function warn(...messages: string[]) {
  if (process.env.NODE_ENV === 'production') {
    return
  }

  const key = messages.join(' ')

  if (!printedWarnings.has(key)) {
    printedWarnings.add(key)
    console.warn('Base UI: ' + key)
  }
}

// Usage - only logs once regardless of how many invalid items
items.forEach(item => {
  if (item.invalid) {
    warn('Item is invalid. Ensure all items have valid IDs.')
  }
})
```

**When to use:**
- All warning utilities
- Warnings that could trigger in loops or rapid re-renders
