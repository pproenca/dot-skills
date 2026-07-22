---
title: Use .output() as a field-leakage control
tags: err, output-validation, data-leakage, error-codes
---

## Use .output() as a field-leakage control

`.output()` reads as the mirror of `.input()` — a runtime restatement of a type the resolver already satisfies — so it gets left off as redundant ceremony. It is not an assertion: tRPC replaces the procedure's result with the *parsed* value, so a Zod object schema genuinely strips unknown keys on the way out. That makes it a field-leakage control at the boundary rather than a type-level nicety, and it is the only one that holds when the shape drifts from underneath — an ORM row that starts carrying `passwordHash` is excluded by the schema, not by anyone remembering. Without it, the response shape is whatever the data layer happens to hand back, which is exactly the thing that changes without a thought for the client.

```ts
import { z } from 'zod';

const memberPublic = z.object({
  id: z.string(),
  displayName: z.string(),
  joinedAt: z.date(),
});

export const memberRouter = router({
  byId: publicProcedure
    .input(z.object({ id: z.string() }))
    .output(memberPublic)
    .query(async ({ input }) => {
      // row also carries passwordHash and internalNotes;
      // the parsed output drops both before serialization
      return db.member.findUniqueOrThrow({ where: { id: input.id } });
    }),
});
```

Because the strip happens at parse time, a new sensitive column added to `member` is excluded by default rather than by remembering to update a `select`. The trade is that a legitimate shape change now fails loudly — and it fails as an `INTERNAL_SERVER_ERROR`, not the `BAD_REQUEST` the `.input()` mirror suggests, because the *server* produced data violating its own contract. That distinction is worth carrying into retry and alerting rules: code written for the symmetric assumption either pages a contract break as an outage, or files a genuine server bug in the "user error" branch where nobody looks.

Reference: [tRPC — Validators: output validators](https://trpc.io/docs/server/validators#output-validators)
