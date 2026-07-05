---
title: Render large or growing LiveView collections with streams
tags: phx, liveview, streams, memory
---

## Render large or growing LiveView collections with streams

Every value in `socket.assigns` is held in server memory for the life of each connected socket and is retained for change tracking. Assigning a large list — a feed, a table of thousands of rows — and appending to it means that whole list lives in memory per connected user and is re-diffed on every update. LiveView **streams** solve this: items are sent to the client and *not* retained on the server, and `stream_insert`/`stream_delete` update individual DOM elements without keeping the collection server-side. Use streams for any collection that is large or grows over the socket's lifetime; keep small, fixed assigns as plain assigns.

```elixir
def mount(_params, _session, socket) do
  {:ok, stream(socket, :messages, Chat.recent_messages())}
end

def handle_info({:new_message, message}, socket) do
  # Appends one DOM node; the server keeps no growing list in memory.
  {:noreply, stream_insert(socket, :messages, message)}
end
```

```heex
<div id="messages" phx-update="stream">
  <div :for={{dom_id, message} <- @streams.messages} id={dom_id}>
    {message.body}
  </div>
</div>
```

Reference: [Phoenix.LiveView — Streams](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#stream/4)
