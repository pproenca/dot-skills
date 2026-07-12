---
title: Fetch by scope, never by bare client id
tags: trust, idor, scopes, data-access
---

## Fetch by scope, never by bare client id

An id arriving in `params` or an event payload is attacker-controlled input, and `Repo.get(Bid, id)` executes it verbatim: increment the id and you are reading — or deleting — another seller's bid. This is textbook IDOR, and it is why Phoenix 1.8's generators thread a scope as the first argument of every context function: `Bids.get_bid!(scope, id)` compiles the actor into the query (`where: b.bidder_id == ^scope.user.id`), so the wrong id returns nothing instead of someone else's row. The shape matters, not the brand — on a pre-1.8 codebase, any fetch that filters by the acting user passes; what fails is the client-supplied id flowing into a fetch that filters by nothing.

**Evidence of violation:** a client-supplied id (`params["id"]` in `mount`/`handle_params`, an id from a `handle_event` payload or `phx-value-*`) passed to an unscoped fetch — `Repo.get`/`Repo.get!` on a schema with an owner or tenant association, or a context function whose signature takes only the id — with no actor filter anywhere on the path. PASS: the fetch goes through a scope-first context function (`get_auction!(%Scope{} = scope, id)`) or the query visibly filters by the current user/organization — cite the fetch site and the filter. N/A: the target performs no lookups from client-supplied ids, or the schemas involved have no owner/tenant association. Carve-out (citable): the resource is genuinely public — cite the route or render showing unauthenticated/any-user access is the design (a public auction listing page), in which case unscoped *reads* of that resource pass; writes never inherit this carve-out.

```elixir
def handle_event("retract_bid", %{"id" => id}, socket) do
  # get_bid!/2 is compiled against the scope: another bidder's id
  # raises Ecto.NoResultsError instead of returning their bid.
  bid = Paddle.Bids.get_bid!(socket.assigns.current_scope, id)
  {:ok, _} = Paddle.Bids.retract_bid(socket.assigns.current_scope, bid)
  {:noreply, stream_delete(socket, :bids, bid)}
end
```

Reference: [Phoenix — Scopes guide](https://hexdocs.pm/phoenix/scopes.html)
