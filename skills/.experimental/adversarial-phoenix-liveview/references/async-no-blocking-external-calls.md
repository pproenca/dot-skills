---
title: Move external calls off the LiveView process
tags: async, assign-async, http-clients, blocking, responsiveness
---

## Move external calls off the LiveView process

A LiveView is one GenServer serving one user's entire UI. A synchronous call to a payment provider or carrier API inside `mount` or `handle_event` blocks every other message — clicks, patches, PubSub broadcasts, form validations — until the third party answers; the page freezes for exactly as long as someone else's p99. The docs frame async operations as the way to "get a working UI quickly while the system fetches some data in the background or talks to an external service, without blocking the render or event handling." Plain `Repo` CRUD is not the target here — it is pool-bounded, local, and milliseconds; the violation is anchored to external-client call *types*, not latency guesses.

**Evidence of violation:** a call to a named external client — `Req.*`, `Finch.request`, `Tesla.*`, `HTTPoison.*`, `:httpc.request`, a report/export builder, `:timer.sleep` — executed synchronously inside `mount/3`, `handle_params/3`, `handle_event/3`, or `handle_info/2` of a LiveView or LiveComponent. PASS: the call runs inside `assign_async`/`start_async`, or in another process the LiveView only messages. Plain Ecto/`Repo` CRUD in handlers is exempt and never evidence for this rule. N/A: no external-client calls occur in LiveView modules in the target. Carve-out (citable): the handler cannot proceed without the response AND the call carries an explicit tight timeout in code (e.g. `receive_timeout: 2_000`) — cite the option at the call site; an unbounded blocking call is never excused by stated intent.

```elixir
def mount(%{"id" => listing_id}, _session, socket) do
  listing = Auctions.get_listing!(socket.assigns.current_scope, listing_id)

  {:ok,
   socket
   |> assign(:listing, listing)
   |> assign_async(:shipping_quote, fn ->
     # Carrier-API latency stays off the LiveView process; clicks,
     # patches, and bid broadcasts keep flowing while the quote loads.
     {:ok, %{shipping_quote: Shipping.quote_for_listing(listing_id)}}
   end)}
end
```

Reference: [Phoenix.LiveView — Async Operations](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#module-async-operations)
