---
title: Derive query keys from the options proxy
tags: client, query-keys, cache, tanstack-query
---

## Derive query keys from the options proxy

When a cache write needs a raw key — `setQueryData`, `getQueryData`, `cancelQueries` — the two defaults are `import { getQueryKey } from '@trpc/react-query'` and then `getQueryKey(trpc.post.byId, { id }, 'query')`, or, when that import fails, hand-rolling the array. `getQueryKey` is not exported from `@trpc/tanstack-react-query`, so the first fails loudly. The second fails quietly: the real key is `[path[], { input, type }]` — or `[prefix[], path[], args]` when the integration is configured with a `keyPrefix`, where the prefix is itself an array segment, not a bare string — so a plausible-looking `['post', 'byId', { id }]` writes to a cache entry nothing reads. The symptom presents as "the optimistic update didn't take" rather than as an error, and it survives review because the array looks right.

The proxy already carries the key builders, so nothing has to be reconstructed: `trpc.post.byId.queryKey({ id })` for one query, `trpc.post.pathKey()` for everything under a sub-router, `trpc.pathKey()` for every tRPC query, plus `trpc.post.list.infiniteQueryKey({ ... })` and `trpc.post.create.mutationKey()`.

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useTRPC } from '~/trpc/react';

export function usePublishPost(id: string) {
  const trpc = useTRPC();
  const queryClient = useQueryClient();

  return useMutation(
    trpc.post.publish.mutationOptions({
      onMutate: async () => {
        const queryKey = trpc.post.byId.queryKey({ id });
        await queryClient.cancelQueries({ queryKey });

        const previous = queryClient.getQueryData(queryKey);
        queryClient.setQueryData(queryKey, (post) =>
          post ? { ...post, status: 'published' as const } : post,
        );

        return { queryKey, previous };
      },
      onError: (_error, _input, context) => {
        if (context) {
          queryClient.setQueryData(context.queryKey, context.previous);
        }
      },
    }),
  );
}
```

Because the key comes from the same proxy node as `queryOptions`, the input is type-checked against the procedure and `getQueryData` returns the procedure's output type rather than `unknown` — the hand-rolled array gives up both.

Reference: [tRPC — TanStack React Query usage: query keys](https://trpc.io/docs/client/tanstack-react-query/usage#queryKey)
