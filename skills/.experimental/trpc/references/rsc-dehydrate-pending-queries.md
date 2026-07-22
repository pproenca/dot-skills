---
title: Dehydrate pending queries so prefetches stream
tags: rsc, dehydrate, prefetch, streaming
---

## Dehydrate pending queries so prefetches stream

The default `QueryClient` for App Router work gets a `staleTime` and nothing else, and prefetching is written fire-and-forget — `void queryClient.prefetchQuery(...)` in a server component so rendering is not blocked on it. TanStack Query's default `shouldDehydrateQuery` only dehydrates queries that have *settled*, and an un-awaited prefetch is still `pending` when the boundary dehydrates. The prefetch is therefore dead weight: the server pays the full fetch, nothing of it reaches the client, and the client refetches from scratch on mount. There is no error and no warning — just the added server load with none of the TTFB improvement the prefetch was added to buy.

Override `dehydrate.shouldDehydrateQuery` to include pending queries, and the un-awaited prefetch streams its result to the client as it resolves.

```tsx
// trpc/query-client.ts
import {
  QueryClient,
  defaultShouldDehydrateQuery,
} from '@tanstack/react-query';

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        // Long enough that the client does not immediately refetch what the server sent
        staleTime: 30_000,
      },
      dehydrate: {
        // Pending queries are excluded by default, which silently drops
        // every `void prefetchQuery(...)` issued during the render
        shouldDehydrateQuery: (query) =>
          defaultShouldDehydrateQuery(query) ||
          query.state.status === 'pending',
      },
    },
  });
}
```

With this in place, `void queryClient.prefetchQuery(trpc.order.list.queryOptions())` behaves as intended: the server component renders immediately, and the client picks up the in-flight query rather than starting its own.

Reference: [tRPC — TanStack React Query: server components](https://trpc.io/docs/client/tanstack-react-query/server-components)
