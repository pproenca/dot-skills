---
title: Initialize tRPC exactly once per application
tags: proc, initTRPC, routers, merge-routers
---

## Initialize tRPC exactly once per application

Generating a router per feature file naturally produces an `initTRPC.create()` per feature file — each one self-contained, each one importable on its own. The routers then get merged or nested into an app router and everything type-checks. The failure comes later and from somewhere else: `mergeRouters()` throws when the routers it is given were built by different instances configured with different `transformer` or `errorFormatter` settings. That is a runtime check, not a type error, so the first sign of it is the server refusing to boot — and the reported symptom is "the app router won't start", several files away from the duplicated `create()` that caused it.

One instance, one file, and every router imports its builders from there.

```ts
// server/trpc.ts — the only initTRPC.create() in the codebase
import { initTRPC } from '@trpc/server';
import superjson from 'superjson';
import type { Context } from './context';

const t = initTRPC.context<Context>().create({
  transformer: superjson,
});

export const router = t.router;
export const middleware = t.middleware;
export const mergeRouters = t.mergeRouters;
export const publicProcedure = t.procedure;

// server/routers/invoice.ts
import { z } from 'zod';
import { publicProcedure, router } from '../trpc';

export const invoiceRouter = router({
  byId: publicProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(({ input }) => db.invoice.findUniqueOrThrow({ where: { id: input.id } })),
});

// server/routers/_app.ts
import { router } from '../trpc';
import { invoiceRouter } from './invoice';
import { memberRouter } from './member';

export const appRouter = router({
  invoice: invoiceRouter,
  member: memberRouter,
});

export type AppRouter = typeof appRouter;
```

Exporting the builders rather than `t` itself is deliberate: nothing outside `trpc.ts` should be able to reconfigure the instance, and the export list doubles as the inventory of what a router file is allowed to use.

Reference: [tRPC — Define routers](https://trpc.io/docs/server/routers)
