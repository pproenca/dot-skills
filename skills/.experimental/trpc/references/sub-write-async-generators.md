---
title: Write subscriptions as async generators
tags: sub, generators, observables, sse, tracked
---

## Write subscriptions as async generators

Nearly every subscription example in circulation returns an observable — `.subscription(() => observable((emit) => { ee.on('add', emit.next); return () => ee.off('add', emit.next); }))` — delivered over `wsLink`. It is the v10 shape, it still compiles, and it still runs, so nothing pushes back. tRPC's own source marks it deprecated with an explicit removal target: using subscriptions with an observable will be removed in v12. The larger cost lands before that. Only the generator path supports `tracked()` and `lastEventId`, so an observable subscription has no automatic reconnect-and-resume — a dropped connection loses every event emitted while it was down, permanently and silently, and the client comes back looking healthy.

Write the resolver as `async function*`, take the abort signal from `opts`, and wrap each yielded value in `tracked()` so the client can resume from where it stopped.

```ts
// server/routers/post.ts
import { on } from 'node:events';
import { tracked } from '@trpc/server';

export const postRouter = router({
  onAdd: publicProcedure
    .input(z.object({ boardId: z.string(), lastEventId: z.string().nullish() }))
    .subscription(async function* (opts) {
      // `opts.signal` aborts the iterator when the client disconnects
      for await (const [post] of on(ee, 'add', { signal: opts.signal })) {
        const data = post as Post;
        if (data.boardId !== opts.input.boardId) continue;
        // the id is what the client sends back as `lastEventId` on reconnect
        yield tracked(data.id, data);
      }
    }),
});
```

Pair it with `httpSubscriptionLink` on the client. The docs recommend SSE as the default transport when you are unsure which to pick; WebSocket remains available via `wsLink` for the same generator resolver, so the transport choice stays independent of the resolver shape.

Reference: [tRPC — Subscriptions](https://trpc.io/docs/server/subscriptions)
