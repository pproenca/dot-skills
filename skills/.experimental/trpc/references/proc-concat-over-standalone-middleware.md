---
title: Compose cross-instance middleware with .concat()
tags: proc, middleware, concat, plugins
---

## Compose cross-instance middleware with .concat()

Middleware that has to work outside the instance that defined it — a shared package, a plugin, anything a library publishes for consumers whose `initTRPC` it has never seen — pulls toward `experimental_standaloneMiddleware<{ ctx: ...; input: ... }>().create(fn)`, because the type parameters look like exactly the escape hatch for that. It is `@deprecated` in favour of `.concat()`, and the same export is aliased as `experimental_trpcMiddleware`, which is deprecated too. The functional limit matters more than the deprecation: a standalone middleware cannot declare `.input()` parsers, so a plugin whose middleware depends on validated input — a rate limiter keyed by organization id, a tenant resolver — has no way to express it and ends up re-parsing the raw payload by hand inside the middleware body.

`.concat()` takes a partial procedure built on its own tRPC instance and attaches it to yours, carrying both its context requirements and its input parsers.

```ts
// packages/rate-limit/src/plugin.ts — the plugin's own instance
import { initTRPC, TRPCError } from '@trpc/server';
import { z } from 'zod';

const t = initTRPC.create();

export const rateLimitPlugin = {
  procedure: t.procedure
    .input(z.object({ organizationId: z.string().uuid() }))
    .use(async (opts) => {
      const allowed = await consumeToken(opts.input.organizationId);
      if (!allowed) {
        throw new TRPCError({ code: 'TOO_MANY_REQUESTS' });
      }
      return opts.next();
    }),
};

// server/routers/invoice.ts — the consuming app's instance
import { publicProcedure, router } from '../trpc';
import { rateLimitPlugin } from '@acme/rate-limit';

const limitedProcedure = publicProcedure.concat(rateLimitPlugin.procedure);

export const invoiceRouter = router({
  list: limitedProcedure.query(({ input }) =>
    db.invoice.findMany({ where: { organizationId: input.organizationId } }),
  ),
});
```

The concatenated input merges with the consumer's own `.input()` under the usual object-spread rule, so a procedure can add its own keys on top of `organizationId` without the plugin knowing about them.

Reference: [tRPC — Middlewares: concat](https://trpc.io/docs/server/middlewares#concat)
