---
title: Read batch link headers from opList
tags: link, headers, batching, auth
---

## Read batch link headers from opList

The remembered `headers` callback is `headers({ op }) { return { authorization: op.context.token } }`, because that is the signature `httpLink` documents and the one most snippets show. Batch links receive `{ opList }` instead — a non-empty array of the operations packed into that request — and only the non-batching `httpLink` receives `{ op }`. Destructuring `op` from a batch link's argument yields `undefined`, so the header expression evaluates to `undefined` and the header is dropped entirely rather than sent empty. Every request then arrives unauthenticated and the server answers `401`, which sends debugging to the token store, the session middleware, and the auth provider before anyone rereads one line of client config.

Because a batch is a single HTTP request, headers cannot vary per operation inside it. Read from the list deliberately — take the first operation's context, or reduce across the list — rather than assuming there is only ever one.

```ts
// trpc/client.ts
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import { authStore } from '~/lib/auth-store';
import type { AppRouter } from '~/server/routers/_app';

export const trpcClient = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/api/trpc',
      headers({ opList }) {
        const token = opList[0]?.context.token ?? authStore.getToken();
        return token ? { authorization: `Bearer ${token}` } : {};
      },
    }),
  ],
});
```

If two operations in a batch genuinely need different credentials, no header callback can express that — split them onto separate links with `splitLink` so each becomes its own request.

Reference: [tRPC — httpBatchLink: options](https://trpc.io/docs/client/links/httpBatchLink#options)
