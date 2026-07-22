---
title: Route subscriptions through httpSubscriptionLink
tags: link, subscriptions, splitlink, sse
---

## Route subscriptions through httpSubscriptionLink

A client is usually set up before the first subscription exists: one `httpBatchLink`, one URL, done. Adding a `.subscription()` procedure later changes the server and the call site but not the link chain, and the link chain is where it breaks. `httpLink` and `httpBatchLink` reject subscription operations outright at runtime — batched HTTP resolves a request and closes it, so there is no way to hold a stream open, and tRPC refuses the operation rather than degrading it into a one-shot response. The throw happens on the first subscribe, not at build time, so it lands in whichever environment first exercises realtime.

Split the chain by operation type and give subscriptions their own terminating link.

```ts
// trpc/client.ts
import {
  createTRPCClient,
  httpBatchLink,
  httpSubscriptionLink,
  splitLink,
} from '@trpc/client';
import type { AppRouter } from '~/server/routers/_app';

const url = 'http://localhost:3000/api/trpc';

export const trpcClient = createTRPCClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => op.type === 'subscription',
      true: httpSubscriptionLink({ url }),
      false: httpBatchLink({ url }),
    }),
  ],
});
```

`httpSubscriptionLink` speaks SSE and pairs with the async-generator subscriptions v11 introduced. `wsLink` is the alternative terminating link for the same branch when the transport has to be WebSocket; the `splitLink` shape is identical either way, only the `true` branch changes.

Reference: [tRPC — httpSubscriptionLink](https://trpc.io/docs/client/links/httpSubscriptionLink#setup)
