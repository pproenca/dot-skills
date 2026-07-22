---
title: Return next({ ctx }) so the guard narrows downstream
tags: proc, middleware, context, type-narrowing
---

## Return next({ ctx }) so the guard narrows downstream

If a procedure body has to re-assert something a middleware already proved, the middleware is not returning it. tRPC derives the downstream context from the object handed to `next()` — whatever you pass is merged into the existing context and its inferred type wins — so a middleware that only *checks* propagates nothing, and the guarantee stops at its own closure. The auth case is the instance everyone meets first: `if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' }); return next();` is correct at runtime and useless at the type level, leaving `ctx.user` as `User | null` in every procedure it protects. Each of those then needs a null check for a case that cannot happen, and the reflex under that pressure is `ctx.user!` — which erases exactly the guarantee the middleware was added to provide, and keeps erasing it after someone later changes the guard.

Re-passing the narrowed value is what propagates the type.

```ts
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(async (opts) => {
  const { ctx } = opts;
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  // re-passing `ctx.user` is what narrows it — `User`, not `User | null`
  return opts.next({ ctx: { user: ctx.user } });
});

// server/routers/invoice.ts
export const invoiceRouter = router({
  listMine: protectedProcedure.query(({ ctx }) =>
    db.invoice.findMany({ where: { ownerId: ctx.user.id } }),
  ),
});
```

The same move covers anything a middleware establishes and downstream code should be able to trust without re-checking — a resolved organization, a decoded API key, a database transaction handle. Read it in the other direction when reviewing: a `!` or a defensive `if` in a procedure body is a report about the middleware above it, not about the procedure.

Reference: [tRPC — Middlewares: context extension](https://trpc.io/docs/server/middlewares#context-extension)
