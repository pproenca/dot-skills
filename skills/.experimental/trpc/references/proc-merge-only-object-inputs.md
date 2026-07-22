---
title: Chain .input() only with object schemas
tags: proc, validators, input-merging, zod
---

## Chain .input() only with object schemas

Because `.use()` stacks, `.input()` looks like it stacks too, and a chain such as `.input(z.string()).input(z.number())` reads as "accept both". tRPC merges inputs by spreading properties, which only means anything for objects: the later schema's keys overwrite the earlier schema's keys, and everything else survives. Non-object validators produce a type error, which is the loud version. The quiet version is the runtime rule underneath it — the spread happens only when *both* sides parse to objects, and otherwise the later parser replaces the earlier one wholesale. The base procedure's validation is then simply gone, and the procedure still runs.

Keep every link in the chain a plain object schema, and the merge is exactly the property spread it looks like.

```ts
// server/trpc.ts
export const organizationProcedure = protectedProcedure
  .input(z.object({ organizationId: z.string().uuid() }))
  .use(assertMembership);

// server/routers/invoice.ts
export const invoiceRouter = router({
  list: organizationProcedure
    .input(
      z.object({
        limit: z.number().min(1).max(100).default(20),
        cursor: z.string().uuid().optional(),
      }),
    )
    // input is { organizationId: string; limit: number; cursor?: string }
    .query(({ input }) =>
      db.invoice.findMany({
        where: { organizationId: input.organizationId },
        take: input.limit,
        cursor: input.cursor ? { id: input.cursor } : undefined,
      }),
    ),
});
```

Overwriting is a feature when you use it deliberately — a specific procedure can tighten a `limit` that a base procedure declared loosely — but it is silent, so a key repeated between a base procedure and its consumer should be a decision, not a coincidence. When two procedures need genuinely unrelated shapes, give them separate base procedures rather than trying to chain a non-object validator onto a shared one.

Reference: [tRPC — Validators: input merging](https://trpc.io/docs/server/validators#input-merging)
