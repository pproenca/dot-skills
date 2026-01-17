---
title: Use Query Key Factories
impact: CRITICAL
impactDescription: eliminates key duplication, enables type-safe invalidation
tags: query, keys, factories, typescript, organization
---

## Use Query Key Factories

Query keys scattered across components lead to typos, inconsistent structure, and broken cache invalidation. A query key factory centralizes key generation for type safety and maintainability.

**Incorrect (scattered keys, easy to break):**

```typescript
// In UserProfile.tsx
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

// In UserSettings.tsx - typo breaks invalidation
const { data } = useQuery({
  queryKey: ['users', userId], // 'users' vs 'user' - different cache!
  queryFn: () => fetchUser(userId),
})

// In mutation - invalidation misses the typo
queryClient.invalidateQueries({ queryKey: ['user'] })
```

**Correct (centralized factory):**

```typescript
// queries/users.ts
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
}

// In UserProfile.tsx
const { data } = useQuery({
  queryKey: userKeys.detail(userId),
  queryFn: () => fetchUser(userId),
})

// In mutation - invalidates all user queries
queryClient.invalidateQueries({ queryKey: userKeys.all })
```

**Benefits:**
- TypeScript autocompletion prevents typos
- Hierarchical structure enables granular invalidation
- Single source of truth for all user-related keys

Reference: [Effective React Query Keys](https://tkdodo.eu/blog/effective-react-query-keys)
