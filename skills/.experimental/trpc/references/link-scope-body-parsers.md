---
title: Scope body parsers away from the tRPC mount path
tags: link, express, adapters, formdata
---

## Scope body parsers away from the tRPC mount path

The reflex ordering in any Express app is `app.use(express.json())` at the top, then everything else below it — including `app.use('/trpc', createExpressMiddleware({ router: appRouter }))`. A global parser consumes the request stream before tRPC ever reads it. Plain JSON procedures usually survive, because the parsed body is close enough to what the adapter expects, so the setup looks correct for as long as the API stays JSON-only. The first `FormData` or binary mutation then fails at runtime with nothing useful attached — the body tRPC needs has already been drained, and the error surfaces as a malformed-input or empty-body complaint rather than as a middleware-ordering problem.

Scope the parser to the routes that actually need it and leave the tRPC mount path untouched.

```ts
// server/index.ts
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import express from 'express';
import { createContext } from '~/server/context';
import { appRouter } from '~/server/routers/_app';

const app = express();

// Body parsing applies to the REST surface only.
app.use('/api', express.json());
app.use('/api/webhooks/stripe', express.raw({ type: 'application/json' }));

// tRPC reads the raw request stream itself.
app.use(
  '/trpc',
  createExpressMiddleware({ router: appRouter, createContext }),
);

app.listen(3000);
```

The same rule holds for any adapter mounted inside a framework that parses bodies by default — Fastify's content-type parsers, Next.js Pages Router API routes with `bodyParser` enabled. Turn the parsing off for the tRPC path rather than working around it downstream.

Reference: [tRPC — Non-JSON content types](https://trpc.io/docs/server/non-json-content-types)
