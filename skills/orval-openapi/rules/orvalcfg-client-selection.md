---
title: Select Client Based on Framework Requirements
impact: CRITICAL
impactDescription: determines bundle size, DX, and caching capabilities
tags: config, client, react-query, swr, axios
---

## Select Client Based on Framework Requirements

Choose the right client option for your framework. Each generates different code with different dependencies and capabilities.

**Incorrect (wrong client for use case):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      client: 'axios',  // Plain axios for React app using TanStack Query
    },
  },
});
```

**Problem:** Manual query setup, no caching, no automatic refetching.

**Correct (framework-appropriate client):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      client: 'react-query',  // Generates useQuery/useMutation hooks
      httpClient: 'fetch',    // Underlying HTTP client
    },
  },
});
```

**Client selection guide:**

| Framework | Client | What's Generated |
|-----------|--------|------------------|
| React + TanStack Query | `react-query` | `useQuery`, `useMutation` hooks |
| React + SWR | `swr` | `useSWR`, `useSWRMutation` hooks |
| Vue + TanStack | `vue-query` | Vue composition API hooks |
| Svelte + TanStack | `svelte-query` | Svelte store-based hooks |
| Angular | `angular` | Injectable services |
| Vanilla JS/Node | `axios` or `fetch` | Plain functions |
| Validation only | `zod` | Zod schemas |

**httpClient options:**
- `fetch` (default): Smaller bundle, native browser API
- `axios`: More features (interceptors, progress), larger bundle

Reference: [Orval Client Options](https://orval.dev/reference/configuration/output)
