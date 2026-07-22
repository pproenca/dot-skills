---
title: Share logic as plain functions, not nested callers
tags: rsc, server-side-calls, caller, composition
---

## Share logic as plain functions, not nested callers

When two procedures need the same work, the natural move is for one to build a server-side caller and invoke the other — the logic is already written, already validated, already authorized. A caller is a full entry point, not a function reference: creating one re-creates the context, re-runs the entire middleware chain, and re-validates the input, all of which the outer call has already done. Context creation is where the expensive work lives — session lookups, database connections, feature-flag reads — so every nested invocation duplicates it, and the cost compounds silently as endpoints get composed on top of each other.

Extract the shared work into a plain function that takes `ctx` and its own arguments, and call it from both procedures.

```ts
// server/services/posts.ts
import type { Context } from '~/server/context';

export async function listPostsForAuthor(
  ctx: Context,
  { authorId, limit = 20 }: { authorId: string; limit?: number },
) {
  return ctx.db.post.findMany({
    where: { authorId, publishedAt: { not: null } },
    orderBy: { publishedAt: 'desc' },
    take: limit,
  });
}

// server/routers/_app.ts
export const appRouter = router({
  post: router({
    list: publicProcedure
      .input(z.object({ authorId: z.string().uuid(), limit: z.number().min(1).max(100).optional() }))
      .query(({ ctx, input }) => listPostsForAuthor(ctx, input)),
  }),
  author: router({
    byId: publicProcedure
      .input(z.object({ authorId: z.string().uuid() }))
      .query(async ({ ctx, input }) => {
        const author = await ctx.db.author.findUniqueOrThrow({ where: { id: input.authorId } });
        // Same work, one context, no second middleware pass
        const posts = await listPostsForAuthor(ctx, { authorId: input.authorId, limit: 5 });
        return { author, posts };
      }),
  }),
});
```

**When NOT to use this pattern:** genuine entry points, where no context exists yet and the middleware chain is the thing you want to run — cron jobs, queue workers, scripts, and integration tests. `router.createCaller()` is the right tool there, and it is fully supported; the rule is about calling it from *inside* a request that already paid for a context.

Reference: [tRPC — Server-side calls](https://trpc.io/docs/server/server-side-calls)
