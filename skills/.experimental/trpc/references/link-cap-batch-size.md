---
title: Cap batch size on both the client and the server
tags: link, batching, limits, production
---

## Cap batch size on both the client and the server

`httpBatchLink({ url })` is the documented starting point and it is almost always left exactly that way, because batching appears to need no tuning — it only ever reduces request count. The defaults are the problem: `maxURLLength` and `maxItems` are both `Infinity`. A dashboard that mounts twenty components in one tick collects all twenty calls into a single request, and that request fails as a unit — `414 URI Too Long` on a GET batch, `413 Payload Too Large` on a POST one, or an opaque `404` from a CDN or proxy enforcing its own URL limit before the request ever reaches the server. Every one of those is load-dependent: local development mounts fewer components against a permissive dev server, so the failure first appears in production and looks like a networking incident. Uncapped batching is also a fan-out surface — one HTTP request can demand an unbounded number of procedure executions.

Cap it on both ends. `maxBatchSize` is new in v11.15.0, and a server that sets it rejects over-sized batches with `400 Bad Request`, so `maxItems` and `maxBatchSize` have to be set as a pair with `maxItems <= maxBatchSize`.

```ts
// trpc/shared.ts
export const MAX_BATCH_SIZE = 20;

// trpc/client.ts
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from '~/server/routers/_app';
import { MAX_BATCH_SIZE } from './shared';

export const trpcClient = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/api/trpc',
      maxURLLength: 2083,
      maxItems: MAX_BATCH_SIZE,
    }),
  ],
});

// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '~/server/routers/_app';
import { createContext } from '~/server/context';
import { MAX_BATCH_SIZE } from '~/trpc/shared';

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext,
    maxBatchSize: MAX_BATCH_SIZE,
  });

export { handler as GET, handler as POST };
```

When either limit is exceeded the link splits the operations across several requests instead of failing, so the cap costs a few extra round trips at the tail and nothing at all in the common case. `maxURLLength: 2083` is the conservative figure — the oldest widely cited browser URL limit — and matters only for GET batches; a lower `maxItems` is what bounds server work.

Reference: [tRPC — httpBatchLink: limiting batch size](https://trpc.io/docs/client/links/httpBatchLink#limiting-batch-size)
