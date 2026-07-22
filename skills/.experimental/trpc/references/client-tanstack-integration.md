---
title: Build React data fetching on the TanStack Query integration
tags: client, react, tanstack-query, setup
---

## Build React data fetching on the TanStack Query integration

The default reflex is `createTRPCReact<AppRouter>()` from `@trpc/react-query`, then calling `trpc.post.list.useQuery()` — the v10 shape that dominates existing tRPC code. In v11 the recommended integration is `@trpc/tanstack-react-query`, which hands you a proxy of *option factories* that you pass to TanStack Query's own hooks. The classic package still works, so nothing breaks loudly; the cost is that it receives no significant new features, its hooks cannot be linted against the rules of hooks, and every later decision in the codebase — invalidation, query keys, prefetching — has to follow it onto the path the docs no longer describe.

The shape to recognize: you no longer call a tRPC hook. You call a TanStack hook and give it `trpc.<path>.queryOptions(input)`.

```tsx
// trpc/react.tsx
import { createTRPCContext } from '@trpc/tanstack-react-query';
import type { AppRouter } from '~/server/routers/_app';

export const { TRPCProvider, useTRPC, useTRPCClient } =
  createTRPCContext<AppRouter>();

// components/post-list.tsx
import { useQuery } from '@tanstack/react-query';
import { useTRPC } from '~/trpc/react';

export function PostList({ authorId }: { authorId: string }) {
  const trpc = useTRPC();
  const { data, isPending } = useQuery(
    trpc.post.list.queryOptions({ authorId }),
  );

  if (isPending) return <PostListSkeleton />;
  return <ul>{data.map((post) => <PostRow key={post.id} post={post} />)}</ul>;
}
```

Because `queryOptions()` returns a plain options object, the same call site composes with anything TanStack Query accepts — `useSuspenseQuery`, `useQueries`, `queryClient.prefetchQuery` — with no tRPC-specific variant of each.

**When NOT to use this pattern:** an existing codebase already standardized on `createTRPCReact`. Query keys are identical between the two integrations, so they can coexist during a migration, but mixing them within one feature makes invalidation ambiguous — migrate by feature, not by file.

Reference: [tRPC — TanStack React Query integration](https://trpc.io/docs/client/tanstack-react-query/setup)
Reference: [tRPC — Introducing the new TanStack React Query integration](https://trpc.io/blog/introducing-tanstack-react-query-client)
