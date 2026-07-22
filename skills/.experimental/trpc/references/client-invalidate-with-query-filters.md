---
title: Invalidate through queryClient with tRPC query filters
tags: client, invalidation, tanstack-query, mutations
---

## Invalidate through queryClient with tRPC query filters

After a mutation, the reflex is `const utils = trpc.useUtils()` — or the older `trpc.useContext()` — followed by `utils.post.invalidate()`. That is the `createTRPCReact` shape, and it is what most tRPC code on the internet looks like. On the `@trpc/tanstack-react-query` proxy there is no `useUtils`: it is not a key of `TRPCOptionsProxy<AppRouter>`, so with types intact the line simply does not compile. The trap is what happens when the router type has degraded to `any` — the version-floor failure in `mig-typescript-version-floor` — because then it survives compilation and throws at render, on the `trpc.useUtils()` line itself, as `contextMap[utilName] is not a function`. That message never names `useUtils`, so debugging starts inside the proxy internals instead of at the one call the codebase needs to stop making.

Invalidation now goes through the `QueryClient` you already have, with the tRPC proxy supplying the filter: `pathFilter()` for every query under a router or sub-router, `queryFilter(input)` for one specific query, `infiniteQueryFilter(input)` for an infinite one.

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useTRPC } from '~/trpc/react';

export function CreatePostForm({ authorId }: { authorId: string }) {
  const trpc = useTRPC();
  const queryClient = useQueryClient();

  const createPost = useMutation(
    trpc.post.create.mutationOptions({
      onSuccess: (post) => {
        // every query under the `post` router — list, byAuthor, counts
        queryClient.invalidateQueries(trpc.post.pathFilter());
        // or just the one row that changed:
        queryClient.invalidateQueries(trpc.post.byId.queryFilter({ id: post.id }));
      },
    }),
  );

  return (
    <form onSubmit={(e) => { e.preventDefault(); createPost.mutate({ authorId, title }); }}>
      {/* ... */}
    </form>
  );
}
```

The diff from the v10 habit is two lines, and the filter call is what carries the path:

**Incorrect (useUtils is not on the new proxy):** `const utils = trpc.useUtils()` … `onSuccess: () => utils.post.invalidate()`
**Correct (invalidate through the query client):** `const queryClient = useQueryClient()` … `onSuccess: () => queryClient.invalidateQueries(trpc.post.pathFilter())`

Prefer the narrowest filter that still refetches what the user can see — `pathFilter()` on a large router invalidates every mounted query beneath it, including ones the mutation could not have affected.

Reference: [tRPC — TanStack React Query usage: query filters](https://trpc.io/docs/client/tanstack-react-query/usage#queryFilter)
