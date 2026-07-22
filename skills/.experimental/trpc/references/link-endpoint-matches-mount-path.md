---
title: Match the fetch adapter endpoint to the real mount path
tags: link, adapters, fetch, nextjs
---

## Match the fetch adapter endpoint to the real mount path

`endpoint` gets treated as a label for the route, so it is set from the file tree and forgotten. It is a prefix the adapter *strips* from the incoming URL to recover the procedure name, which means it has to match the path that reaches the handler at runtime — and under a rewrite, a `basePath`, or an edge function mounted behind a prefix, that path is not the one in the repository layout. A mismatch leaves the leftover segment glued to the procedure name, the router genuinely has no procedure by that name, and every call returns `404` with nothing in the message pointing at this option.

```ts
// app/api/trpc/[trpc]/route.ts — deployed behind a rewrite from /gateway/*
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { createContext } from '~/server/context';
import { appRouter } from '~/server/routers/_app';

const handler = (req: Request) =>
  fetchRequestHandler({
    // the URL tRPC receives, not the directory this file lives in
    endpoint: '/gateway/trpc',
    req,
    router: appRouter,
    createContext,
  });

export { handler as GET, handler as POST };
```

The client's `url` and the adapter's `endpoint` describe the same runtime path from two sides. Derive both from one constant whenever the mount path can move, and check the value against the rewrite table rather than the file tree.

Reference: [tRPC — Fetch adapter](https://trpc.io/docs/server/adapters/fetch)
