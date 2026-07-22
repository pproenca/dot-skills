---
title: Set isDev explicitly so stack traces never ship
tags: err, isdev, stack-traces, security
---

## Set isDev explicitly so stack traces never ship

Nobody configures `isDev`, because production is assumed to hide stack traces on its own. It hides them only where the ambient environment cooperates: `isDev` defaults to `process.env.NODE_ENV !== 'production'`, and on edge and serverless runtimes `NODE_ENV` is frequently not set at all. The default then evaluates to `true` in production, and `error.data.stack` is serialized into every error response — including responses to unauthenticated requests, which turns any thrown error into a free map of your file paths, package layout and internal call sites. The docs recommend overriding it manually when you want deterministic behavior across runtimes; derive it from a flag your build controls, or set `isDev: false` outright in the production build.

```ts
import { initTRPC } from '@trpc/server';
import { errorFormatter } from './error-formatter';

// APP_ENV is set by our own build/deploy config, not by the runtime
const isDev = process.env.APP_ENV === 'development';

const t = initTRPC.context<Context>().create({
  isDev,
  errorFormatter,
});
```

Pinning the flag to an app-level variable also makes the behavior testable: an integration test can assert that a thrown `INTERNAL_SERVER_ERROR` comes back without a `stack` key, which an implicit `NODE_ENV` dependency cannot express. Note that `isDev` governs the stack trace only — the `message` of a non-`TRPCError` throw still reaches the client, so anything genuinely secret belongs in the log call, not in the thrown error.

Reference: [tRPC — Error handling: stack traces in production](https://trpc.io/docs/server/error-handling)
