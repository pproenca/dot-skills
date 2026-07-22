---
title: Gate responseMeta cache headers on auth, type, and errors
tags: link, caching, responsemeta, security
---

## Gate responseMeta cache headers on auth, type, and errors

Asked to shave latency off a tRPC endpoint, the obvious move is a blanket `responseMeta: () => ({ headers: new Headers([['cache-control', 's-maxage=60, stale-while-revalidate=300']]) })`. That is a security hole, and the mechanism is specific to tRPC rather than to HTTP caching in general: batching is on by default, so one HTTP response can carry a public procedure *and* a personal one. A shared CDN caches that whole response under a single key and then serves user A's data to user B. The docs state the constraint directly — set cache headers in `responseMeta`, and make sure no concurrent call in the batch includes personal data. The same blanket header also caches errors and mutation responses, pinning a transient failure in front of every user for the full TTL.

Three gates, all of them required: no authenticated context, no errors, and queries only.

```ts
// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '~/server/routers/_app';
import { createContext } from '~/server/context';

const PUBLIC_PATHS = new Set([
  'marketing.pricingTiers',
  'catalog.listCategories',
]);

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext,
    responseMeta({ ctx, paths, type, errors }) {
      const isPublicBatch =
        !ctx?.user && paths?.every((path) => PUBLIC_PATHS.has(path));

      if (isPublicBatch && type === 'query' && errors.length === 0) {
        return {
          headers: new Headers([
            ['cache-control', 's-maxage=60, stale-while-revalidate=300'],
          ]),
        };
      }

      return {};
    },
  });

export { handler as GET, handler as POST };
```

`paths.every(...)` against an explicit allowlist is what makes the gate hold: one private procedure joining the batch drops the header for the whole response, which is the correct direction to fail. Where public and private traffic genuinely differ in volume, stop classifying per response and separate them at the transport — a `splitLink` sending public procedures to a cacheable endpoint and everything else to an uncacheable one gives the CDN two URL namespaces it cannot confuse.

Reference: [tRPC — Response caching](https://trpc.io/docs/server/caching)
