---
title: Keep Repo and Ecto.Query out of web modules
tags: bound, contexts, repo, data-access
---

## Keep Repo and Ecto.Query out of web modules

A `Repo.get` inside a `handle_event` works today and scatters tomorrow: the query's filter logic now lives in one LiveView, invisible to the API controller, the Oban job, and the seed script that write and read the same rows. The contexts guide states the design directly — the context module "centralizes all functionality related to posts, instead of scattering logic around controllers, LiveViews, etc." — and Phoenix 1.8's scope pattern depends on it, because scope filtering enforced in context functions protects nothing when web modules bypass them with raw `Repo` calls. The LiveView's job is UI state; every read and write goes through a named context function that all callers share.

**Evidence of violation:** a `Repo.` call (`Repo.get`, `Repo.all`, `Repo.insert`, any function on the app's Repo module), an `alias`/`import` of the app Repo, or `import Ecto.Query` inside a module under `lib/*_web/` — a LiveView, LiveComponent, or web-side helper. PASS: web modules obtain and mutate data only through context functions (`Auctions.get_auction!(scope, id)`, `Auctions.place_bid(scope, auction, attrs)`); cite the call sites checked. N/A: the target's web modules contain no data access at all. No carve-out — an "it is only one query" inline `Repo` call is the violation, not an exception; move it behind a context function even if that function is one line.

```elixir
# lib/paddle_web/live/auction_live/show.ex
def handle_event("place_bid", %{"bid" => bid_params}, socket) do
  scope = socket.assigns.current_scope

  case Paddle.Auctions.place_bid(scope, socket.assigns.auction, bid_params) do
    {:ok, bid} -> {:noreply, assign(socket, :highest_bid, bid)}
    {:error, changeset} -> {:noreply, assign(socket, :bid_form, to_form(changeset))}
  end
end
```

Reference: [Phoenix — Contexts guide](https://hexdocs.pm/phoenix/contexts.html)
