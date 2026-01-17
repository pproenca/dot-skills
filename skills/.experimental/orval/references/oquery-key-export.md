---
title: Export Query Keys for Cache Invalidation
impact: MEDIUM-HIGH
impactDescription: enables proper cache invalidation patterns
tags: oquery, react-query, queryKey, invalidation
---

## Export Query Keys for Cache Invalidation

Enable query key exports to use React Query's invalidation and prefetching APIs. Without exported keys, you must hardcode key strings, breaking when generated code changes.

**Incorrect (hardcoded query keys):**

```typescript
// orval.config.ts - query key export disabled by default
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
    },
  },
});
```

**Fragile invalidation with hardcoded keys:**
```typescript
const queryClient = useQueryClient();

const createUser = useCreateUser({
  onSuccess: () => {
    // Hardcoded key - breaks if Orval changes key format
    queryClient.invalidateQueries({ queryKey: ['/users'] });
  },
});
```

**Correct (exported query keys):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          shouldExportQueryKey: true,
        },
      },
    },
  },
});
```

**Type-safe invalidation:**
```typescript
import { getGetUsersQueryKey } from '@/api/users';

const queryClient = useQueryClient();

const createUser = useCreateUser({
  onSuccess: () => {
    // Type-safe, follows generated key format
    queryClient.invalidateQueries({ queryKey: getGetUsersQueryKey() });
  },
});
```

**Prefetching with exported keys:**
```typescript
// Prefetch on hover
const prefetchUser = (userId: string) => {
  queryClient.prefetchQuery({
    queryKey: getGetUserQueryKey(userId),
    queryFn: () => getUser(userId),
  });
};
```

**When NOT to use this pattern:**
- Very small projects where cache invalidation is handled manually
- Not using React Query's programmatic APIs (invalidateQueries, prefetchQuery)

Reference: [TanStack Query Invalidation](https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation)
