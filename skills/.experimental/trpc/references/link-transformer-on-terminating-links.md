---
title: Configure the data transformer on every terminating link
tags: link, transformer, superjson, serialization
---

## Configure the data transformer on every terminating link

The remembered shape is `createTRPCClient<AppRouter>({ transformer: superjson, links: [httpBatchLink({ url })] })` — one transformer, declared once, next to the links. In v11 the client-side transformer moved *into* the link: `httpBatchLink({ url, transformer: superjson })`. The server did not move; it still takes `initTRPC.create({ transformer: superjson })`. The v10 shape does produce a compile error, but a branded one — the client's option type resolves to `TypeError<'The transformer property has moved to httpLink/httpBatchLink/wsLink'>`, which reads like a type-level complaint about the property rather than an instruction. The dangerous follow-up is deleting the property to make the red squiggle go away: that compiles cleanly, and then the client either throws `Unable to transform response from server` or silently degrades `Date`, `Map`, and `Set` to their JSON shapes, so a timestamp arrives as a string and every comparison against it starts lying.

Both sides have to agree, and they are now configured in two different places.

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import superjson from 'superjson';

const t = initTRPC.context<Context>().create({
  transformer: superjson,
});

export const router = t.router;
export const publicProcedure = t.procedure;

// trpc/client.ts
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import superjson from 'superjson';
import type { AppRouter } from '~/server/routers/_app';

export const trpcClient = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/api/trpc',
      transformer: superjson,
    }),
  ],
});
```

The transformer belongs on terminating links only — `httpLink`, `httpBatchLink`, `httpSubscriptionLink`, `wsLink`. Middleware links such as `loggerLink` and `splitLink` pass operations through and take no transformer of their own.

That makes every branch of a `splitLink` its own terminating link with its own `transformer` — nesting inherits nothing, and the compiler holds the line, rejecting a bare branch with `Property 'transformer' is missing in type '{ url: string; }'`. The branch worth thinking about is the non-JSON-serializable one: an `httpLink` carrying `FormData`, `File`, or `Blob` takes `transformer: { serialize: (data) => data, deserialize: (data) => superjson.deserialize(data) }`, so the multipart body leaves untransformed while the response still comes back transformed. Copying `transformer: superjson` onto that branch to make the branches match re-encodes a body the server expects raw — the asymmetry is the point, not an oversight.

Reference: [tRPC — Data transformers](https://trpc.io/docs/server/data-transformers)
