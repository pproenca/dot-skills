---
title: Read unvalidated input with await getRawInput()
tags: mig, middleware, context, input
---

## Read unvalidated input with await getRawInput()

Middleware that needs the payload before validation — audit logging, tenant routing, rate-limit keys — gets written as `t.middleware(({ rawInput }) => ...)`, the v10 shape. v11 materializes inputs lazily, so `rawInput` is no longer on the options object: it is `undefined` at runtime. Nothing in the middleware signature is narrow enough to make that a compile error you cannot talk yourself past, so the failure lands as a null tenant or an empty audit row in production. The replacement is `await opts.getRawInput()`, which is async precisely because the body has not been read yet.

Treat what comes back as `unknown`. It is the pre-validation payload — no schema has run, and on a public procedure it is attacker-controlled.

```ts
import { TRPCError, initTRPC } from '@trpc/server';
import { z } from 'zod';

const t = initTRPC.context<Context>().create();

const tenantScoped = t.middleware(async (opts) => {
  const raw = await opts.getRawInput();

  // unvalidated: narrow before trusting any field
  const parsed = z.object({ orgId: z.string().uuid() }).safeParse(raw);
  if (!parsed.success) {
    throw new TRPCError({ code: 'BAD_REQUEST' });
  }

  await auditLog.record({
    userId: opts.ctx.userId,
    path: opts.path,
    orgId: parsed.data.orgId,
  });

  return opts.next({ ctx: { orgId: parsed.data.orgId } });
});

export const orgProcedure = t.procedure.use(tenantScoped);
```

The same laziness removes input and procedure type from `createContext` entirely — by the time context is built, the body has not been consumed. Per-request work that wants the payload either moves into a middleware like the one above, or reaches it through the batch call info: `info.calls[index].getRawInput()`. Prefer the middleware; `info.calls` is an array because one HTTP request may carry several procedures, and code that assumes `calls[0]` is *the* call silently reads a neighbour's input under batching.

Reference: [tRPC — Migrate from v10 to v11](https://trpc.io/docs/migrate-from-v10-to-v11)
