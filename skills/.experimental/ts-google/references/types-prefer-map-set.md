---
title: Prefer Map and Set Over Index Signatures
impact: HIGH
impactDescription: O(1) operations with proper typing
tags: types, map, set, indexable, collections
---

## Prefer Map and Set Over Index Signatures

Use `Map` and `Set` instead of objects with index signatures for better type safety, predictable iteration order, and O(1) operations.

**Incorrect (index signature objects):**

```typescript
// Loose typing, prototype pollution risk
const userScores: { [key: string]: number } = {}
userScores['alice'] = 100
userScores['bob'] = 85

// Checking existence is awkward
if (userScores['charlie'] !== undefined) {
  // ...
}

// toString, hasOwnProperty are valid keys (prototype issues)
```

**Correct (Map/Set):**

```typescript
// Type-safe, no prototype pollution
const userScores = new Map<string, number>()
userScores.set('alice', 100)
userScores.set('bob', 85)

// Clear existence check
if (userScores.has('charlie')) {
  const score = userScores.get('charlie')!
}

// For unique values
const activeUsers = new Set<string>()
activeUsers.add('alice')
activeUsers.add('bob')
```

**When to use index signatures:**
- JSON serialization (Map doesn't serialize cleanly)
- Known, finite set of keys: use Record type instead

```typescript
type UserRole = 'admin' | 'user' | 'guest'
const permissions: Record<UserRole, string[]> = {
  admin: ['read', 'write', 'delete'],
  user: ['read', 'write'],
  guest: ['read'],
}
```

Reference: [Google TypeScript Style Guide - Indexable types](https://google.github.io/styleguide/tsguide.html#indexable-types)
