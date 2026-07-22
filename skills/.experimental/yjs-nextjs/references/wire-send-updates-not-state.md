---
title: Broadcast incremental updates rather than whole document state
tags: wire, bandwidth, state-vector, sync
---

## Broadcast incremental updates rather than whole document state

`Y.encodeStateAsUpdate(doc)` is the function that appears in every Yjs example, so it becomes the thing that gets called on every change and pushed to every peer. It encodes the entire document. The `update` event already hands you exactly the bytes that changed: on a 5,000-character document, one keystroke produced a 24-byte update against a 5,041-byte full state — a ratio that widens as the document grows, so the cost of the mistake scales with the length of the editing session.

**Incorrect (whole document per keystroke):**

```typescript
doc.on('update', () => {
  socket.send(Y.encodeStateAsUpdate(doc)) // 5041 bytes for a one-character edit
})
```

**Correct (only the delta, and only when it originated locally):**

```typescript
doc.on('update', (update, origin) => {
  if (origin === 'remote') return // do not echo back what the peer just sent us
  socket.send(update) // 24 bytes for a one-character edit
})
```

Full state still has one correct use — catching a peer up when it joins — and even then it should be scoped to what that peer is missing by passing its state vector, so the reply carries only the difference:

```typescript
// Client announces what it already has; server replies with just the gap.
socket.send(Y.encodeStateVector(doc))

// Server side:
const missing = Y.encodeStateAsUpdate(serverDoc, clientStateVector)
```

Reference: [Yjs — Document Updates](https://docs.yjs.dev/api/document-updates)
