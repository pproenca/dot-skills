---
title: Keep room state outside the function instance on Vercel
tags: host, vercel, scaling, websocket
---

## Keep room state outside the function instance on Vercel

Vercel Functions serve WebSockets as of June 2026, so the natural move is to lift the reference server's in-memory room registry into a Vercel Function unchanged. That registry assumes every client of a document reaches the same process, and Vercel documents the opposite: "New WebSocket connections are not guaranteed to reach the same Vercel Function instance." Two people editing one brief can land on different instances, each broadcasting to a private copy of the room — both see a working editor, neither sees the other's typing, and the divergence only surfaces when the documents are later merged. Connections are also cut when the function hits its max duration (300s on Hobby, up to 800s on Pro), so reconnection is routine rather than exceptional.

**Incorrect (module-level registry assumes one process owns the room):**

```typescript
const rooms = new Map<string, Y.Doc>() // lives in one instance only

export function getRoom(briefId: string) {
  let doc = rooms.get(briefId)
  if (!doc) rooms.set(briefId, (doc = new Y.Doc()))
  return doc
}
```

**Correct (every update crosses a shared channel, so instances stay convergent):**

```typescript
import { createClient } from 'redis'
import * as Y from 'yjs'

const publisher = createClient({ url: process.env.REDIS_URL })
const subscriber = publisher.duplicate()
const ready = Promise.all([publisher.connect(), subscriber.connect()])

export async function joinRoom(briefId: string, socket: WebSocket) {
  await ready
  const channel = `brief:${briefId}`
  const doc = new Y.Doc()

  // Hydrate from durable storage, not from whatever this instance happens to hold.
  const snapshot = await loadSnapshot(briefId)
  if (snapshot) Y.applyUpdate(doc, snapshot, 'storage')

  await subscriber.subscribe(channel, (message) => {
    Y.applyUpdate(doc, Buffer.from(message, 'base64'), 'peer')
  })

  doc.on('update', (update, origin) => {
    if (origin === 'peer' || origin === 'storage') return // do not re-publish what we just received
    void publisher.publish(channel, Buffer.from(update).toString('base64'))
  })
}
```

Vercel's guidance is the same in general form: "Store durable state, presence, counters, rooms, and pub/sub coordination in an external data store instead of relying on in-memory variables." A managed Yjs backend does all of this for you — see [`host-websocket-server-is-not-production`](host-websocket-server-is-not-production.md).

Reference: [Vercel — WebSockets](https://vercel.com/docs/functions/websockets)
