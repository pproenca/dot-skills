---
title: Use tRPC for authorization and snapshots, not for the sync loop
tags: host, trpc, subscriptions, architecture
---

## Use tRPC for authorization and snapshots, not for the sync loop

In a tRPC codebase every server interaction goes through a procedure, so Yjs sync gets modelled as a subscription that streams updates down and a mutation that pushes them up. That fails on transport semantics rather than on style. `httpSubscriptionLink` is Server-Sent Events — a one-way channel whose `input` is serialized into the URL once at connect time, so there is no way to keep sending updates through it. The upstream half has its own limits: binary procedure input is accepted only on POST mutations, and only through `httpLink`, so `httpBatchLink` needs a `splitLink` to carry it at all. What you end up with is two transports with independent lifecycles and no ordering guarantee between them, replacing one bidirectional socket.

**Incorrect (a subscription treated as a duplex sync channel):**

```typescript
export const briefRouter = router({
  // Updates only ever flow server -> client here. `tracked()` does make the
  // downstream half resumable, which is exactly why this looks viable — but the
  // client still has no way to push its own edits back through the subscription.
  sync: publicProcedure
    .input(z.object({ briefId: z.string() }))
    .subscription(async function* ({ input }) {
      for await (const update of briefUpdates(input.briefId)) {
        yield tracked(update.id, update.bytes)
      }
    }),
})
```

**Correct (tRPC authorizes and persists; a WebSocket provider carries the loop):**

```typescript
export const briefRouter = router({
  // 1. Authorize the room and mint a short-lived token for the sync service.
  joinRoom: protectedProcedure
    .input(z.object({ briefId: z.string() }))
    .mutation(async ({ ctx, input }) => {
      await assertCanEditBrief(ctx.session.userId, input.briefId)
      return { room: `brief:${input.briefId}`, token: await mintCollabToken(input.briefId) }
    }),

  // 2. Persist compacted snapshots on the same authenticated path.
  saveSnapshot: protectedProcedure
    .input(z.object({ briefId: z.string(), update: z.string() })) // base64, see wire-base64-not-superjson
    .mutation(async ({ input }) => {
      await saveBriefSnapshot(input.briefId, Buffer.from(input.update, 'base64'))
    }),
})
```

```typescript
// The sync loop itself never touches tRPC.
const { room, token } = await trpc.brief.joinRoom.mutate({ briefId })
const provider = new WebsocketProvider(collabUrl, room, doc, { params: { token } })
```

**When NOT to use this pattern:** a strictly read-only viewer needs no upstream channel, and an SSE subscription that streams updates into a local `Y.Doc` is a legitimate way to build one without running a WebSocket service.

Reference: [tRPC — httpSubscriptionLink](https://trpc.io/docs/client/links/httpSubscriptionLink)
