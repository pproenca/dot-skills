---
title: Use push_patch within the LiveView you are already in
tags: state, navigation, push-patch, lifecycle
---

## Use push_patch within the LiveView you are already in

`push_navigate` (and `<.link navigate>`) dismounts the current LiveView and mounts a new one: every assign, every stream, every subscription, and scroll position are destroyed, and `mount/3` re-runs from zero. For sort, filter, pagination, tab, or detail-panel changes inside the same LiveView, that teardown buys nothing — `push_patch` (and `<.link patch>`) keeps the process alive, updates the URL, and invokes only `handle_params/3`. The wrong assumption is that navigation is navigation; the docs split it explicitly: patch "when you want to navigate to the current LiveView, simply updating the URL", navigate "when you want to dismount the current LiveView and mount a new one." A remount where a patch suffices re-fetches everything the process already held and visibly resets the UI mid-session.

**Evidence of violation:** a `push_navigate/2` call or `<.link navigate={...}>` whose target route resolves (per the router) to the *same LiveView module* currently rendering, within the same `live_session`. PASS: `push_patch`/`<.link patch>` used for same-module targets; navigate used only toward a different LiveView module. N/A: the target contains no LiveView navigation. Carve-out (citable): the same module is mounted under a *different* `live_session` in the router — crossing live_sessions forces a full reload and patch is impossible there; cite the two `live_session` blocks. A bare claim that a remount was intended does not pass — fail closed.

```elixir
def handle_event("sort", %{"by" => by}, socket) do
  # Same AuctionLive.Index, new params — the process, its streams, and its
  # PubSub subscriptions survive; only handle_params/3 runs.
  {:noreply, push_patch(socket, to: ~p"/auctions?#{[sort: by]}")}
end
```

Reference: [Phoenix.LiveView — Live navigation](https://hexdocs.pm/phoenix_live_view/live-navigation.html)
