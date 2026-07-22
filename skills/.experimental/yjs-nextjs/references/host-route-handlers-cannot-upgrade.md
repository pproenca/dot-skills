---
title: Run the sync backend outside the Next.js request lifecycle
tags: host, websocket, deployment, route-handlers
---

## Run the sync backend outside the Next.js request lifecycle

The obvious place to put a Yjs server is `app/api/collab/route.ts`, and it will look correct in review — but App Router route handlers have no socket-upgrade API, so the handler returns a response and the connection dies. Next.js states the limitation directly: "WebSockets won't work because the connection closes on timeout, or after the response is generated." A Yjs sync server needs a process whose lifetime is independent of any one request.

**Incorrect (upgrade attempted inside a route handler):**

```typescript
// app/api/collab/[briefId]/route.ts
import { WebSocketServer } from 'ws'

const wss = new WebSocketServer({ noServer: true })

export async function GET(request: Request) {
  // There is no upgrade socket to hand to `wss` here, and the module-level
  // `wss` is discarded whenever the serverless instance recycles.
  return new Response('expected websocket', { status: 426 })
}
```

**Correct (long-lived process; Next.js only hands the client its URL):**

```typescript
// server/collab.ts — deployed as its own always-on service, not as a Next.js route
import http from 'node:http'
import { WebSocketServer } from 'ws'
import { setupWSConnection } from '@y/websocket-server/utils'

const server = http.createServer((_, res) => res.writeHead(200).end('ok'))
const wss = new WebSocketServer({ noServer: true })

wss.on('connection', setupWSConnection)
server.on('upgrade', (req, socket, head) => {
  wss.handleUpgrade(req, socket, head, (ws) => wss.emit('connection', ws, req))
})

server.listen(1234)
```

```typescript
// components/brief-editor.tsx — the Next.js app is a client of that service
const provider = new WebsocketProvider(
  process.env.NEXT_PUBLIC_COLLAB_URL!, // wss://collab.example.com
  `brief:${briefId}`,
  doc,
)
```

**Alternative (Vercel-hosted, accepting its constraints):** Vercel Functions serve WebSockets via `experimental_upgradeWebSocket()` from `@vercel/functions` when Fluid compute is enabled. It is Vercel-specific and experimental, and Vercel's own reference says "when possible, you should handle WebSocket connections using native Node.js APIs instead." If you take it, read [`host-vercel-lacks-instance-affinity`](host-vercel-lacks-instance-affinity.md) first — the routing model changes how you must hold room state.

Reference: [Next.js — Backend for Frontend](https://nextjs.org/docs/app/guides/backend-for-frontend)
