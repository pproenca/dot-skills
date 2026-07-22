---
title: Enable SSE keepalive explicitly
tags: sub, sse, keepalive, reconnect, config
---

## Enable SSE keepalive explicitly

A subscription that works on localhost ships with no keepalive at all: `ping.enabled` defaults to `false` and `reconnectAfterInactivityMs` defaults to `undefined`, so a stream with nothing to emit puts nothing on the wire and the client has no rule for when to give up on it. The first intermediary with an idle timeout — an nginx proxy, a load balancer, a serverless gateway — reaps the connection, and because the client was never told to reconnect after inactivity, the subscription just stops delivering. It presents as a flaky network or an unstable server, and only on deployed infrastructure, since a direct dev connection has no proxy in the middle to close it. Turn on the ping and set the inactivity timeout together — they are one mechanism, a heartbeat and the patience for it, and enabling either alone leaves the gap open.

Both halves are server-side configuration; the docs are explicit that the timeout is set on the server when initializing tRPC, and `httpSubscriptionLink` has no option for it. The ping interval has to be lower than the timeout, which tRPC enforces rather than tolerates: an inverted pair throws `Ping interval must be less than client reconnect interval to prevent unnecessary reconnection` when the stream is constructed.

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';

const t = initTRPC.create({
  sse: {
    enabled: true,
    ping: {
      // off by default — an idle stream sends nothing without this
      enabled: true,
      intervalMs: 15_000,
    },
    client: {
      // undefined by default — the client never reconnects on silence
      reconnectAfterInactivityMs: 20_000,
    },
  },
});
```

Size the pair against the shortest idle timeout on the path, not against how fast you want recovery to feel: a 15s heartbeat is already below the 30–60s idle window most proxies ship with. In v11 these options live under `sse` on `initTRPC.create()`, having moved out of `experimental.sseSubscriptions` — code carrying the experimental key is configuring nothing, which is another way to end up with the defaults.

Reference: [tRPC — httpSubscriptionLink: server ping](https://trpc.io/docs/client/links/httpSubscriptionLink#server-ping)
