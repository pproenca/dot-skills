---
title: Keep subscription credentials out of the URL
tags: sub, auth, connection-params, eventsource, sse
---

## Keep subscription credentials out of the URL

`httpSubscriptionLink` exposes `connectionParams`, an async function returning a key-value bag, and it reads exactly like the purpose-built hook for authenticating a stream — so tokens go straight into it. `connectionParams` are serialized into the **URL query string**. The token then lands in server access logs, proxy and CDN logs, and browser history: stores that outlive the session, are replicated to places nobody audits, and are almost never treated as secret storage. The docs note this is precisely why the other methods are preferred. Nothing fails, so the leak is only ever found by someone reading logs.

Same-origin subscriptions need nothing special — `EventSource` sends cookies, so an existing session cookie already authenticates the stream. Cross-origin and native clients ponyfill `EventSource` and pass real headers instead. The condition that matters below is `op.type === 'subscription'`, which is where the credentials decision attaches; see `link-route-subscriptions-separately` for the general `splitLink` shape.

```ts
// trpc/client.ts
import {
  createTRPCClient,
  httpBatchLink,
  httpSubscriptionLink,
  splitLink,
} from '@trpc/client';
import { EventSourcePolyfill } from 'event-source-polyfill';
import type { AppRouter } from '~/server/routers/_app';

export const trpcClient = createTRPCClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => op.type === 'subscription',
      true: httpSubscriptionLink({
        url: 'https://api.example.com/trpc',
        // credentials travel in headers, not in the query string
        EventSource: EventSourcePolyfill,
        eventSourceOptions: async () => ({
          headers: { authorization: `Bearer ${await getAccessToken()}` },
        }),
      }),
      false: httpBatchLink({ url: 'https://api.example.com/trpc' }),
    }),
  ],
});
```

`eventSourceOptions` is re-invoked per connection, so a token refreshed between reconnects is picked up without rebuilding the client. Reserve `connectionParams` for values you would be comfortable seeing in an access log — a room id, a client version, a locale.

Reference: [tRPC — httpSubscriptionLink: connection params](https://trpc.io/docs/client/links/httpSubscriptionLink#connectionParams)
