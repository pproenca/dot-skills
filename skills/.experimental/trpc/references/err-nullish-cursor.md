---
title: Type infinite-query cursors as .nullish()
tags: err, infinite-query, cursor, input-validation
---

## Type infinite-query cursors as .nullish()

A cursor is absent on the first page, so the reflex is `cursor: z.string().optional()` — it types the call site correctly and the first screen of results loads. What arrives on every subsequent fetch is whatever `getNextPageParam` returned, and the idiomatic end-of-list sentinel across tRPC's own examples is `nextCursor: null`: the value the server hands out round-trips straight back into the input, and `initialCursor: null` or an explicit `{ cursor: null }` input reach the validator as `null` too. `.optional()` accepts `undefined` but rejects `null`, so it fails on precisely the value the pagination contract produces — a `400 Bad Request` on a list that paginated fine until the page where the sentinel appears. `.nullish()` accepts both and closes the loop symmetrically, which is why the official example annotates the field as `z.number().nullish(), // <-- "cursor" needs to exist, but can be any type`.

```ts
import { z } from 'zod';

export const postRouter = router({
  list: publicProcedure
    .input(
      z.object({
        limit: z.number().min(1).max(50).default(20),
        cursor: z.string().nullish(),
      }),
    )
    .query(async ({ input }) => {
      const posts = await db.post.findMany({
        take: input.limit + 1,
        cursor: input.cursor ? { id: input.cursor } : undefined,
        orderBy: { createdAt: 'desc' },
      });

      const nextCursor =
        posts.length > input.limit ? posts.pop()!.id : null;

      return { posts, nextCursor };
    }),
});
```

Returning `nextCursor: null` on the last page rather than `undefined` keeps the round trip symmetric — the value the server hands out is exactly the value the input schema accepts back. Nothing injects a cursor behind your back: tRPC spreads the key into the input only when the page param is defined, so `.nullish()` buys nothing on the first page and everything on the ones where your own sentinel comes home.

Reference: [tRPC — useInfiniteQuery](https://trpc.io/docs/client/react/useInfiniteQuery)
