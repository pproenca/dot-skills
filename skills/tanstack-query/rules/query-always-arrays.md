---
title: Always Use Array Query Keys
impact: HIGH
impactDescription: consistent structure, prevents string/array mismatch bugs
tags: query, keys, arrays, consistency
---

## Always Use Array Query Keys

String query keys get converted to arrays internally, causing confusion when mixing formats. Always use arrays for consistency and to enable the hierarchical key pattern.

**Incorrect (mixed string and array keys):**

```typescript
// String key
const { data: user } = useQuery({
  queryKey: 'currentUser', // Internally becomes ['currentUser']
  queryFn: fetchCurrentUser,
})

// Array key elsewhere
const { data: settings } = useQuery({
  queryKey: ['currentUser', 'settings'],
  queryFn: fetchUserSettings,
})

// Invalidation confusion - does this match the string key?
queryClient.invalidateQueries({ queryKey: ['currentUser'] }) // Yes, but not obvious
```

**Correct (always arrays):**

```typescript
// Always arrays, even for single elements
const { data: user } = useQuery({
  queryKey: ['currentUser'],
  queryFn: fetchCurrentUser,
})

const { data: settings } = useQuery({
  queryKey: ['currentUser', 'settings'],
  queryFn: fetchUserSettings,
})

// Clear invalidation hierarchy
queryClient.invalidateQueries({ queryKey: ['currentUser'] }) // Matches both
```

**Note:** TanStack Query v5 TypeScript types enforce arrays, but runtime still accepts strings for backwards compatibility.
