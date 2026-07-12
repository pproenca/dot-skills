---
title: Load patch-varying data in handle_params, lifecycle-constant data in mount
tags: state, handle-params, mount, data-loading
---

## Load patch-varying data in handle_params, lifecycle-constant data in mount

`mount/3` runs once per LiveView lifecycle; `handle_params/3` runs after mount and again on every patch. Put a load in the wrong one and the failure is silent in dev: data derived from patchable params but assigned only in `mount` goes stale the moment the first `push_patch` arrives (the filter changes, the list doesn't), while a params-independent query inside `handle_params` re-executes on every sort click and pagination step, multiplying database load for identical results. The docs draw the line verbatim: "Only the params you expect to be changed via `<.link patch={...}>` or `push_patch/2` must be loaded on `handle_params/3`" — everything else loads in `mount/3`.

**Evidence of violation:** either leg fails: (a) an assign computed from params that the module itself patches (a `push_patch` or `<.link patch>` elsewhere in the module changes those params) is set only in `mount/3` and never recomputed in `handle_params/3`; (b) a query or context call with no dependency on `params` or `uri` executes inside `handle_params/3`. PASS: params-derived loads live in `handle_params/3`; params-independent loads live in `mount/3`. N/A: the LiveView defines no `handle_params/3` and nothing patches to it. Carve-out (citable): a params-independent load inside `handle_params/3` guarded so it runs at most once (an `assign_new/3` or an explicit `Map.has_key?(socket.assigns, ...)` guard) — cite the guard; an unguarded load does not pass.

```elixir
def mount(_params, _session, socket) do
  # Loaded once per lifecycle — no patch changes the category set.
  {:ok, assign(socket, :categories, Paddle.Auctions.list_categories())}
end

def handle_params(params, _uri, socket) do
  # Re-runs on every push_patch — the filtered list follows the URL.
  {:noreply, stream(socket, :auctions, Paddle.Auctions.filter(params), reset: true)}
end
```

Reference: [Phoenix.LiveView — Live navigation](https://hexdocs.pm/phoenix_live_view/live-navigation.html)
