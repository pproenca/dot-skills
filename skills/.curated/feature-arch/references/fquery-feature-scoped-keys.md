---
title: Use Feature-Scoped Query Keys
impact: MEDIUM-HIGH
impactDescription: Enables targeted cache invalidation; prevents accidental cache collisions
tags: query, cache, keys, tanstack-query
---

## Use Feature-Scoped Query Keys

Query keys should be hierarchical with the feature name as the root. This enables precise cache invalidation and prevents key collisions between features.

**Incorrect (flat, collision-prone keys):**

```typescript
// src/features/user/hooks/useUser.ts
useQuery({ queryKey: ['user', userId], ... });

// src/features/admin/hooks/useUser.ts
useQuery({ queryKey: ['user', userId], ... });  // Collides with above!

// Hard to invalidate all user queries
queryClient.invalidateQueries({ queryKey: ['user'] });  // Might affect admin too
```

**Correct (feature-scoped key factory):**

```typescript
// src/features/user/query-keys.ts
export const userKeys = {
  all: ['user'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// src/features/user/hooks/useUser.ts
import { userKeys } from '../query-keys';

export function useUser(userId: string) {
  return useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => getUser(userId),
  });
}

// src/features/admin/query-keys.ts
export const adminUserKeys = {
  all: ['admin', 'user'] as const,
  detail: (id: string) => [...adminUserKeys.all, 'detail', id] as const,
};
```

**Invalidation patterns:**

```typescript
// Invalidate all user data
queryClient.invalidateQueries({ queryKey: userKeys.all });

// Invalidate only user lists (not details)
queryClient.invalidateQueries({ queryKey: userKeys.lists() });

// Invalidate specific user
queryClient.invalidateQueries({ queryKey: userKeys.detail(userId) });
```

**Benefits:**
- Clear ownership of cache keys
- Predictable invalidation scope
- No accidental cross-feature cache interference

Reference: [TanStack Query - Query Keys](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)
