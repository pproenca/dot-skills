---
title: Use placeholderData vs initialData Correctly
impact: HIGH
impactDescription: prevents stale data bugs and incorrect cache behavior
tags: cache, placeholderData, initialData, loading, ux
---

## Use placeholderData vs initialData Correctly

`placeholderData` and `initialData` both show data immediately, but they have different cache semantics. Wrong choice causes stale data or unexpected refetches.

**initialData**: Persisted to cache, affects staleTime, used as real data.
**placeholderData**: Not persisted, never affects staleTime, purely for UI.

**Incorrect (initialData for preview data):**

```typescript
// Using initialData for a preview - BAD!
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  initialData: { name: 'Loading...', id: userId }, // Fake data in cache!
  staleTime: 5 * 60 * 1000,
})
// Problem: "Loading..." is now cached for 5 minutes!
// If user navigates away and back, they see "Loading..." as real data
```

**Correct (placeholderData for preview):**

```typescript
// placeholderData for UI preview - GOOD!
const { data, isPlaceholderData } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  placeholderData: { name: 'Loading...', id: userId },
  staleTime: 5 * 60 * 1000,
})

// isPlaceholderData tells you if showing placeholder
return (
  <div className={isPlaceholderData ? 'opacity-50' : ''}>
    {data.name}
  </div>
)
```

**When to use initialData:**

```typescript
// Cache-to-cache: use detail from list
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  initialData: () => {
    // Get from cached list if available
    const users = queryClient.getQueryData<User[]>(['users'])
    return users?.find(u => u.id === userId)
  },
  initialDataUpdatedAt: () => {
    // Use list's updatedAt for staleTime calculation
    return queryClient.getQueryState(['users'])?.dataUpdatedAt
  },
})
```

**Summary:**
- `placeholderData`: Temporary UI, not cached, for skeletons/previews
- `initialData`: Real data, cached, for cache-to-cache or server-provided data
