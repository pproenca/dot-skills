---
title: Authorize every event handler, not the button
tags: trust, authorization, handle-event, attack-surface
---

## Authorize every event handler, not the button

Rendering the "Close auction" button only for the seller feels like authorization — it is not. Every `handle_event` clause is a public endpoint: any connected client can open the browser console and push any event name with any payload, whether or not the template ever rendered a control for it. The security-model guide is explicit — "you must always verify permissions on the server." The check belongs in the handler's own execution path: either an in-handler permission check or a scope-threaded context call that enforces ownership in the query. A scope-first context call *is* the check — `Paddle.Auctions.close_auction(socket.assigns.current_scope, id)` that filters by the scope's user needs no redundant inline guard on top. What fails is the handler that performs the privileged action with neither.

**Evidence of violation:** a `handle_event` clause that performs a mutating or privileged action (a context write call, a `Repo` write, a broadcastable state change) with neither an in-handler permission check (`current_scope`/role comparison, an authorization module call) nor a scope-first context call — the payload flows from the event straight into an unscoped write. Template-level gating (`:if={@current_scope.user.id == @auction.seller_id}` around the button) is not evidence of a check. PASS: every mutating `handle_event` in the target either calls a context function whose first argument is the scope/actor, or performs an explicit permission check before the write — cite the handler and the check for each. N/A: the target's `handle_event` clauses are all read-only or pure-presentation (no writes, no privileged transitions). Carve-out (citable): the action is genuinely unprivileged for every authenticated user by design — cite the context function or policy showing the write is scoped to the caller's own data and cannot touch another user's rows.

```elixir
def handle_event("close_auction", %{"id" => id}, socket) do
  # The scope-first context call is the authorization: close_auction/2
  # fetches the auction through the seller's scope, so another user's
  # id raises instead of closing someone else's auction.
  auction = Paddle.Auctions.close_auction!(socket.assigns.current_scope, id)
  {:noreply, stream_insert(socket, :auctions, auction)}
end
```

Reference: [Phoenix.LiveView — Security considerations (events)](https://hexdocs.pm/phoenix_live_view/security-model.html)
