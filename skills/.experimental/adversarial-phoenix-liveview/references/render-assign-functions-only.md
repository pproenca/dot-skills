---
title: Mutate assigns only through assign functions
tags: render, change-tracking, assigns, socket
---

## Mutate assigns only through assign functions

`socket.assigns` looks like a plain map, and `Map.put(socket.assigns, :watcher_count, n)` or `%{socket | assigns: ...}` compiles without a warning — but the diff engine never sees the write. Change tracking is maintained by `assign/2,3`, `assign_new/3`, and `update/3`, which record what changed in the socket's `__changed__` bookkeeping; the guide is explicit that if you modify assigns any other way, "those assigns inside your HEEx template will not update after the initial render." The failure is the worst kind: the server-side state is correct, the client keeps showing the old value, and the next unrelated full render papers over it. Reading `socket.assigns` is fine everywhere; every write goes through the assign functions.

**Evidence of violation:** `Map.put(socket.assigns, ...)` or `Map.merge(socket.assigns, ...)` whose result is placed back on the socket, a struct update `%{socket | assigns: ...}`, or `put_in(socket.assigns...)` in any LiveView or LiveComponent callback. PASS: all assign writes in the target flow through `assign`/`assign_new`/`update` — cite the callbacks checked. N/A: the target writes no assigns (pure template or context changes).

```elixir
def handle_event("watch", _params, socket) do
  Auctions.watch(socket.assigns.current_scope, socket.assigns.auction)
  {:noreply, update(socket, :watcher_count, &(&1 + 1))}
end
```

Reference: [Assigns and HEEx templates — Modifying assigns](https://hexdocs.pm/phoenix_live_view/assigns-eex.html)
