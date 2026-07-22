---
title: Default to httpBatchLink, not the streaming variant
tags: link, batching, streaming, headers
---

## Default to httpBatchLink, not the streaming variant

`httpBatchStreamLink` reads like the better `httpBatchLink` — same batching, results arrive as they resolve — and scaffolding tools put it in enough starter clients that it has become muscle memory. The docs name `httpBatchLink` as the recommended terminating link, and the difference is not performance but capability: a streaming response has already begun sending by the time later procedures finish, so `httpBatchStreamLink` cannot set response headers. Any procedure that rotates a session cookie or refreshes an auth token has its `Set-Cookie` silently dropped, with no error on either side. The symptom is users logged out at unpredictable intervals, traced to session storage or cookie flags rather than to the link choice.

The second half of the same trap is naming: v11 dropped the `unstable_` prefix. `unstable_httpBatchStreamLink` and `unstable_httpSubscriptionLink` still resolve, as deprecated aliases of the stable exports, so code reproducing the old names compiles and leaves the codebase describing a stable link as experimental.

```ts
// trpc/client.ts
import { createTRPCClient, httpBatchLink, loggerLink } from '@trpc/client';
import type { AppRouter } from '~/server/routers/_app';

export const trpcClient = createTRPCClient<AppRouter>({
  links: [
    loggerLink({ enabled: (op) => op.direction === 'down' && op.result instanceof Error }),
    // Switch to httpBatchStreamLink only when results must arrive incrementally —
    // it cannot set response headers once the stream has started.
    httpBatchLink({ url: '/api/trpc' }),
  ],
});
```

**When NOT to use this pattern:** two cases make `httpBatchStreamLink` the deliberate choice. The first is latency — a batch whose slowest procedure holds up genuinely useful earlier results, such as a dashboard where one panel queries a slow analytics store. The second is capability, and it is not optional: v11 lets a procedure return promises and async iterables *embedded in its output*, and that output only resolves over a streaming link. Under `httpBatchLink` an embedded promise never settles on the client, with no error to explain it, so a router using the feature has to be reached through `httpBatchStreamLink` — route those procedures down a `splitLink` branch if the rest of the app needs response headers.

Reference: [tRPC — Links overview](https://trpc.io/docs/client/links)
