---
title: Treat the reference WebSocket server as a starting point
tags: host, persistence, backend, websocket
---

## Treat the reference WebSocket server as a starting point

`npx y-websocket` boots in one line and syncs correctly, which reads as production-ready — so it ships. Its maintainer says otherwise: the package "is intended as a **development server** or as a **starting point** for building your own backend," and the y-websocket README adds that it "can't be scaled easily." Documents live in memory and are lost on restart. The persistence recipe is the half that has quietly moved: `YPERSISTENCE` still works in `@y/websocket-server@0.1.1` — the last release on the Yjs 13 track — but is commented out from 0.1.2 onward, so the same deployment command silently persists nothing after an upgrade. Wire persistence programmatically and the code survives that move.

**Incorrect (a recipe that stops working on upgrade, with no error to say so):**

```bash
# Works on 0.1.1; from 0.1.2 this flag is ignored and the server is memory-only.
HOST=0.0.0.0 PORT=1234 YPERSISTENCE=./briefs npx y-websocket
```

**Correct (persistence wired programmatically, writing incrementally):**

```typescript
import { setPersistence } from '@y/websocket-server/utils'
import * as Y from 'yjs'

setPersistence({
  provider: null, // required by the declared type, unused by the server
  bindState: async (briefId, doc) => {
    const stored = await loadBriefUpdates(briefId)
    if (stored.length > 0) Y.applyUpdate(doc, Y.mergeUpdates(stored), 'storage')

    // Persist as changes happen — `writeState` alone only runs when the last client leaves.
    doc.on('update', (update, origin) => {
      if (origin === 'storage') return
      void appendBriefUpdate(briefId, update)
    })
  },
  writeState: async (briefId, doc) => {
    await saveBriefSnapshot(briefId, Y.encodeStateAsUpdate(doc))
  },
})
```

The `bindState` documentation makes the incremental part explicit — subscribe to `ydoc.on('update', ...)` there so you can "persist updates incrementally as they happen, rather than only on shutdown." Without it, a crashed server loses everything written since the last client disconnected.

**Alternative (a maintained backend instead of your own):** the same README points at [YHub](https://github.com/yjs/yhub) — the official Yjs backend, currently beta and dual-licensed AGPL/proprietary — and [Hocuspocus](https://tiptap.dev/hocuspocus). Hocuspocus, [Liveblocks](https://liveblocks.io), and [y-partyserver](https://github.com/cloudflare/partykit) (the Cloudflare Durable Objects successor to the acquired PartyKit) all still declare a Yjs 13 peer dependency and all released within the last month; YHub is the one tracking the v14 line. Check publish dates before adopting any of them — `y-sweet` has had no release since September 2025 and no commit since December 2025, though it carries no deprecation notice.

Reference: [y-websocket-server README](https://github.com/yjs/y-websocket-server/blob/main/README.md)
