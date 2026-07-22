---
title: Prefetch through the server options proxy, not a caller
tags: rsc, prefetch, hydration, options-proxy
---

## Prefetch through the server options proxy, not a caller

In a server component the direct route is obvious: build a caller, `await` the procedure, pass the result down as props. It type-checks, it renders, and it looks like the fastest possible path to the data. What it skips is the query cache. A caller returns a plain value, so nothing is stored under the procedure's query key — and a client component below that renders `useQuery(trpc.post.list.queryOptions({ authorId }))` for the same procedure fetches it again over HTTP. The data is rendered twice and fetched twice, and with `useSuspenseQuery` the client suspends on a request the server already answered. Hydration is the entire point of prefetching on the server, and a direct caller bypasses it.

Expose the router to server components through `createTRPCOptionsProxy` in a `server-only` module, prefetch against the request's `QueryClient`, and dehydrate around the subtree that consumes it.

```tsx
// trpc/server.tsx
import 'server-only';
import { cache } from 'react';
import { createTRPCOptionsProxy } from '@trpc/tanstack-react-query';
import { createRscContext } from '~/server/context';
import { appRouter } from '~/server/routers/_app';
import { makeQueryClient } from './query-client';

export const getQueryClient = cache(makeQueryClient);

export const trpc = createTRPCOptionsProxy({
  // zero-argument factory: there is no incoming `req` here, so this is not the
  // `createContext` the fetch adapter takes
  ctx: createRscContext,
  router: appRouter,
  queryClient: getQueryClient,
});

// app/authors/[authorId]/page.tsx
import { HydrationBoundary, dehydrate } from '@tanstack/react-query';
import { getQueryClient, trpc } from '~/trpc/server';
import { PostList } from '~/components/post-list';

export default async function AuthorPage({
  params,
}: {
  params: Promise<{ authorId: string }>;
}) {
  const { authorId } = await params;
  const queryClient = getQueryClient();

  // Un-awaited: the render is not blocked, and the pending query dehydrates
  void queryClient.prefetchQuery(trpc.post.list.queryOptions({ authorId }));

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostList authorId={authorId} />
    </HydrationBoundary>
  );
}
```

`PostList` stays an ordinary client component calling `useQuery` — it needs no knowledge that a server prefetched for it. That is the property props-drilling from a caller destroys.

The `ctx` factory is where the RSC path diverges from the adapter. `fetchRequestHandler` hands `createContext` a `FetchCreateContextFnOptions` with the live `req`; `createTRPCOptionsProxy` calls its factory with no arguments, because a server component renders outside any request handler. Reusing the adapter's `createContext` here fails to compile (`Target signature provides too few arguments`) — the RSC context builds itself, typically wrapped in `cache()` so one render tree shares one context.

Reference: [tRPC — TanStack React Query: server components](https://trpc.io/docs/client/tanstack-react-query/server-components)
