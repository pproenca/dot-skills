---
title: Format validation issues from Standard Schema, not just Zod
tags: err, error-formatter, validators, standard-schema
---

## Format validation issues from Standard Schema, not just Zod

The `errorFormatter` everyone copies branches on one library: `error.cause instanceof ZodError ? error.cause.flatten() : null`. Which error class you actually catch is decided by tRPC's parser dispatch, which is **ordered**: a function carrying `.assert` (ArkType) matches first, then `.parse` / `.parseAsync` (Zod), and only what falls through both reaches the Standard Schema branch. So Zod keeps throwing `ZodError`, Valibot and Effect Schema throw `StandardSchemaV1Error` — exported from `@trpc/server`, carrying `.issues: ReadonlyArray<StandardSchemaV1.Issue>` — and a validator matched earlier throws its own shape entirely (ArkType throws `ArkErrors`). The `: null` arm swallows everything it does not recognize: field-level detail silently becomes `null` on the client, the form falls back to one generic message, and nobody notices until a user complains that the page "just says something went wrong". Branch on the classes your validators actually produce, not on Zod alone.

The formatter's return shape is inferred all the way to the client, so whatever key you expose is what `error.data.<key>` is typed as — which is also why omitting `errorFormatter` entirely leaves the client with only a flat message string and the whole validation UX to rebuild by hand.

```ts
import { initTRPC, StandardSchemaV1Error } from '@trpc/server';
import { ZodError } from 'zod';

const t = initTRPC.context<Context>().create({
  errorFormatter({ shape, error }) {
    const issues =
      error.cause instanceof ZodError
        ? error.cause.issues.map((issue) => ({
            path: issue.path,
            message: issue.message,
          }))
        : error.cause instanceof StandardSchemaV1Error
          ? error.cause.issues.map((issue) => ({
              path: issue.path ?? [],
              message: issue.message,
            }))
          : null;

    return { ...shape, data: { ...shape.data, issues } };
  },
});
```

With one normalized `issues` key, the invoice form maps `error.data.issues` onto fields without knowing which validator the router was built with — and swapping Valibot in for Zod later stays a server-side change.

One note on Zod-side drift: on Zod 4 `.flatten()` is deprecated in favour of `z.treeifyError()`. Follow the sibling `zod` skill for that; the tRPC-side contract here is only which error class you catch.

Reference: [tRPC — Error formatting](https://trpc.io/docs/server/error-formatting), [tRPC — Validators: library integrations](https://trpc.io/docs/server/validators#library-integrations)
