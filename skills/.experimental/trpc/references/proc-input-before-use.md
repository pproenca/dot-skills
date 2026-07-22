---
title: Declare .input() before the middleware that reads it
tags: proc, middleware, validation, builder-order
---

## Declare .input() before the middleware that reads it

Written in the order the logic sounds — guard first, then accept the payload — a reusable procedure comes out as `t.procedure.use(checkOrgAccess).input(z.object({ organizationId: z.string() }))`. The builder does not read as prose. Middlewares run in registration order and `.input()` *is* a middleware, so a `.use()` registered before it runs **before validation**. TypeScript catches the naive version of this — `opts.input` types as `UnsetMarker` if you touch it directly — but it cannot catch a middleware that side-effects on the raw payload, and those are exactly the middlewares people write: rate limiting keyed by organization id, audit logging, tenant routing. Each of them then runs on unvalidated, attacker-controlled data, and the chain still reads sensibly in review.

Put `.input()` first. The docs' own reusable base procedure has this shape: `authedProcedure.input(...).use(...)`.

```ts
// server/trpc.ts
export const organizationProcedure = protectedProcedure
  .input(z.object({ organizationId: z.string().uuid() }))
  .use(async (opts) => {
    const { ctx, input } = opts;

    const member = await db.member.findFirst({
      where: { organizationId: input.organizationId, userId: ctx.user.id },
    });
    if (!member) {
      throw new TRPCError({ code: 'FORBIDDEN' });
    }

    return opts.next({ ctx: { member } });
  });

// server/routers/invoice.ts
export const invoiceRouter = router({
  list: organizationProcedure
    .input(z.object({ limit: z.number().min(1).max(100).default(20) }))
    .query(({ ctx, input }) =>
      db.invoice.findMany({
        where: { organizationId: input.organizationId },
        take: input.limit,
        // `ctx.member` exists because the middleware proved it
        include: { auditTrail: ctx.member.role === 'admin' },
      }),
    ),
});
```

The bug is a transposition, nothing more:

**Incorrect (middleware sees unvalidated input):** `protectedProcedure.use(checkOrgAccess).input(z.object({ organizationId: z.string().uuid() }))`
**Correct (validation runs first):** `protectedProcedure.input(z.object({ organizationId: z.string().uuid() })).use(checkOrgAccess)`

Read any procedure chain top to bottom as an execution order, not as a description. Anything a `.use()` depends on has to appear above it.

Reference: [tRPC — Procedures: reusable base procedures](https://trpc.io/docs/server/procedures#reusable-base-procedures)
