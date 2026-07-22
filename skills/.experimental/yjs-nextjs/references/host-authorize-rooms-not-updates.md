---
title: Authorize at the room boundary because updates cannot be validated
tags: host, security, authorization, validation
---

## Authorize at the room boundary because updates cannot be validated

In a tRPC codebase every write is `.input(schema)`, so the reflex is to validate the sync payload the same way. A Yjs update is an opaque binary encoding of CRDT operations, not a document — you cannot Zod-parse it, cannot check that it only touches fields this user may edit, and cannot reject part of it while accepting the rest. Anyone who can reach the room can rewrite any field in it. The reference server compounds this by shipping with no authentication at all: `setupWSConnection` accepts every socket and joins it to whatever room the URL names, so an unguarded deployment lets any client read and write any document by guessing an id.

Because per-field authorization is unavailable, the trust boundary has to be the room, and anything a user must not be able to forge has to live outside the document.

**Incorrect (schema validation implies the payload is trustworthy):**

```typescript
// Parses, and proves nothing — the bytes are still arbitrary CRDT operations
// that may set `status: "approved"` or rewrite another team's section.
applyUpdate: publicProcedure
  .input(z.object({ briefId: z.string(), update: z.base64() }))
  .mutation(async ({ input }) => {
    await appendBriefUpdate(input.briefId, Buffer.from(input.update, 'base64'))
  })
```

**Correct (authorize the room, then keep privileged state out of the document):**

```typescript
// The socket is authenticated before it is joined to a room.
wss.on('connection', async (socket, request) => {
  const claims = await verifyCollabToken(new URL(request.url!, 'ws://x').searchParams.get('token'))
  if (!claims || !(await canEditBrief(claims.userId, claims.briefId))) {
    socket.close(4401, 'unauthorized')
    return
  }
  setupWSConnection(socket, request, { docName: `brief:${claims.briefId}` })
})
```

```typescript
// Approval is a server-owned transition, not a field in the shared document.
approveBrief: protectedProcedure
  .input(z.object({ briefId: z.string() }))
  .mutation(async ({ ctx, input }) => {
    await assertCanApprove(ctx.session.userId, input.briefId)
    await db.brief.update({ where: { id: input.briefId }, data: { status: 'approved' } })
  })
```

The dividing line is whether a field's value is a collaborative decision or an authority claim. Body copy, task ordering and titles belong in the document, where the worst case is a bad edit anyone can undo. Status, permissions, pricing and anything auditable belong in the database behind an authorized procedure, because a document field is writable by every participant in the room by construction. Read-only participants need the same treatment — a viewer whose socket accepts updates is an editor, so enforce it when the connection is established rather than in the interface.

Reference: [y-websocket-server README](https://github.com/yjs/y-websocket-server/blob/main/README.md)
