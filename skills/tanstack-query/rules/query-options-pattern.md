---
title: Use queryOptions for Type-Safe Sharing
impact: HIGH
impactDescription: type-safe prefetching and cache access
tags: query, queryOptions, typescript, prefetching
---

## Use queryOptions for Type-Safe Sharing

When sharing query configuration between `useQuery`, `prefetchQuery`, and `getQueryData`, inline objects lose type inference. The `queryOptions` helper preserves types across all usage sites.

**Incorrect (repeated configuration, lost types):**

```typescript
// In component
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

// In prefetch - duplicated, no type link
await queryClient.prefetchQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

// getQueryData returns unknown
const user = queryClient.getQueryData(['user', userId])
// user is unknown, need manual cast
```

**Correct (queryOptions shares types):**

```typescript
// Define once with queryOptions
const userQueryOptions = (userId: string) =>
  queryOptions({
    queryKey: ['user', userId] as const,
    queryFn: () => fetchUser(userId),
  })

// In component - fully typed
const { data } = useQuery(userQueryOptions(userId))

// In prefetch - same options, same types
await queryClient.prefetchQuery(userQueryOptions(userId))

// getQueryData is now typed!
const user = queryClient.getQueryData(userQueryOptions(userId).queryKey)
// user is User | undefined, not unknown
```

**Combine with query key factories:**

```typescript
export const userQueries = {
  detail: (userId: string) =>
    queryOptions({
      queryKey: userKeys.detail(userId),
      queryFn: () => fetchUser(userId),
    }),
  list: (filters: UserFilters) =>
    queryOptions({
      queryKey: userKeys.list(filters),
      queryFn: () => fetchUsers(filters),
    }),
}

// Usage
const { data } = useQuery(userQueries.detail(userId))
await queryClient.prefetchQuery(userQueries.list({ role: 'admin' }))
```

Reference: [TanStack Query - TypeScript](https://tanstack.com/query/v5/docs/react/typescript)
