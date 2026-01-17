---
title: Configure Default Query Options Globally
impact: MEDIUM-HIGH
impactDescription: reduces boilerplate, ensures consistent caching behavior
tags: oquery, react-query, options, staleTime
---

## Configure Default Query Options Globally

Configure default query options in Orval config instead of repeating them in every hook call. This ensures consistent caching behavior across your application.

**Incorrect (options repeated per hook):**

```typescript
// Every component sets the same options
const { data: user } = useGetUser(userId, {
  staleTime: 5 * 60 * 1000,
  gcTime: 10 * 60 * 1000,
  retry: 2,
});

const { data: orders } = useGetOrders({
  staleTime: 5 * 60 * 1000,  // Duplicated
  gcTime: 10 * 60 * 1000,    // Duplicated
  retry: 2,                   // Duplicated
});
```

**Correct (global defaults in config):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          useQuery: true,
          useMutation: true,
          options: {
            staleTime: 5 * 60 * 1000,
            gcTime: 10 * 60 * 1000,
            retry: 2,
          },
        },
      },
    },
  },
});
```

**Clean component usage:**
```typescript
// Defaults applied automatically
const { data: user } = useGetUser(userId);
const { data: orders } = useGetOrders();

// Override only when needed
const { data: liveData } = useGetMetrics({
  staleTime: 0,  // Override for real-time data
  refetchInterval: 5000,
});
```

**Per-operation overrides:**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      override: {
        operations: {
          getMetrics: {
            query: {
              options: {
                staleTime: 0,
                refetchInterval: 5000,
              },
            },
          },
        },
      },
    },
  },
});
```

Reference: [Orval Query Options](https://orval.dev/guides/react-query)
