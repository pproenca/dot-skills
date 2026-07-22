---
title: Attach the event listener before fetching the backlog
tags: sub, generators, tracked, last-event-id, race
---

## Attach the event listener before fetching the backlog

A resume-capable subscription reads most naturally in chronological order: replay what was missed, then start listening. `const missed = await db.getEventsSince(lastEventId); for (const e of missed) yield e; for await (const [e] of on(ee, 'add')) yield e;`. Everything between the database read resolving and the listener attaching is dropped — the emitter has no subscriber during that window, and the rows were already read, so the events exist in neither path. That gap is exactly what `tracked()` and `lastEventId` reconnection exist to close, so the bug defeats the feature it is part of. The window is milliseconds wide, which means it never reproduces locally and surfaces only under production write volume, as users quietly missing updates with no error anywhere.

Create the iterable first, then fetch history, then drain the iterable. Live events emitted during the backlog query buffer in the iterable instead of vanishing.

```ts
// server/routers/comment.ts
import { tracked } from '@trpc/server';

export const commentRouter = router({
  onAdd: publicProcedure
    .input(z.object({ postId: z.string(), lastEventId: z.string().nullish() }))
    .subscription(async function* (opts) {
      // 1. subscribe first — buffers anything emitted during step 2
      const iterable = ee.toIterable('add', { signal: opts.signal });

      // 2. only now read the backlog
      const backlog = await db.comment.findMany({
        where: { postId: opts.input.postId },
        cursor: opts.input.lastEventId ? { id: opts.input.lastEventId } : undefined,
        skip: opts.input.lastEventId ? 1 : 0,
        orderBy: { id: 'asc' },
      });

      // 3. history, then live
      const seen = new Set<string>();
      for (const comment of backlog) {
        seen.add(comment.id);
        yield tracked(comment.id, comment);
      }
      for await (const [comment] of iterable) {
        if (comment.postId !== opts.input.postId) continue;
        if (seen.delete(comment.id)) continue; // already replayed from the backlog
        yield tracked(comment.id, comment);
      }
    }),
});
```

The ordering trades a lost-event race for a duplicate-event overlap, which is the right trade: an event delivered twice is deduplicable by id, an event never delivered is not recoverable. Write the three steps with the comment attached — the sequence is the entire correctness argument, and a later edit that "tidies" the fetch above the subscribe reintroduces the bug invisibly.

Reference: [tRPC — Subscriptions: tracked()](https://trpc.io/docs/server/subscriptions#tracked)
