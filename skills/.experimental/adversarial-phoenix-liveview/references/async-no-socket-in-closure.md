---
title: Extract values before the closure, never capture the socket
tags: async, closures, socket-copy, memory
---

## Extract values before the closure, never capture the socket

`assign_async` and `start_async` run their function in a separate Task process, and everything the closure captures is copied there. Capture `socket` and the copy is the whole thing — every assign, every stream, every form struct — duplicated per async call, per user. The docs are verbatim: "it is important to not pass the socket into the function as it will copy the whole socket struct to the Task process, which can be very expensive." The task needs two or three values; bind them to locals first and let the closure capture only those.

**Evidence of violation:** the anonymous function passed to `assign_async`/`start_async` (or to a `Task.Supervisor` call made from a LiveView) references `socket` or `socket.assigns` in its body. PASS: every value the closure uses is bound to a local variable above the call and the closure references only those locals. N/A: the target contains no async closures in LiveView modules. Carve-out: none — there is no legitimate reason to capture the socket in an async closure; this rule fails closed with no exceptions.

```elixir
def handle_event("watch", %{"id" => listing_id}, socket) do
  scope = socket.assigns.current_scope

  {:noreply,
   start_async(socket, :watch_listing, fn ->
     # Only `scope` and `listing_id` are copied into the task —
     # not the socket with its streams, forms, and every other assign.
     Auctions.watch_listing(scope, listing_id)
   end)}
end
```

Reference: [Phoenix.LiveView.assign_async/4](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#assign_async/4)
