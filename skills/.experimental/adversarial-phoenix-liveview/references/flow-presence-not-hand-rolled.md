---
title: Track who is online with Presence, not a hand-rolled process map
tags: flow, presence, tracking, distributed-state
---

## Track who is online with Presence, not a hand-rolled process map

Who's-watching state looks like a map in a GenServer — add on join, remove on leave — and that version works in every demo. It fails in exactly the ways that never show up locally: a LiveView process that crashes or a client that drops without the leave message leaves a ghost entry forever (nothing monitors the tracked process); a second node has its own map, so the watcher count depends on which node you ask; a netsplit heals and the maps disagree with no merge rule. `Phoenix.Presence` exists because this is a distributed-systems problem with a solved shape: it monitors each tracked process (crash and disconnect clean up automatically), replicates via CRDT with deterministic conflict resolution across nodes and netsplits, and delivers diffs over PubSub. The brand is not the requirement — the *shape* is: monitored cleanup plus multi-node conflict semantics. A hand-rolled tracker has neither until it reimplements both.

**Evidence of violation:** an online/watching/connected-users feature implemented as a custom GenServer, Agent, or ETS table mapping users/sockets to liveness, maintained by explicit join/leave calls or broadcasts from LiveView `mount`/`terminate` — with no `Process.monitor` on the tracked process and no cross-node merge mechanism. `terminate/2` as the leave hook is itself evidence (kills and crashes skip it). PASS: `Phoenix.Presence` (`track/4` from a `connected?` guard, `presence_diff` handling or `Presence.list`); or (citable, shapes not brands) a custom tracker that demonstrably monitors tracked processes *and* resolves multi-node conflicts — cite both mechanisms (the `Process.monitor`/`:DOWN` handling and the replication/merge path, e.g. `Phoenix.Tracker` behaviour callbacks). Missing either mechanism fails closed. This gate judges only the *choice* of a monitored, replicated tracker for the online-UI feature; the internal distribution correctness of a custom tracker (merge protocol, netsplit behavior) is the sibling gate `adversarial-beam`'s territory — do not judge CRDT internals here. N/A: the target tracks no liveness/online state.

```elixir
# lib/paddle_web/live/auction_live/show.ex — monitored, replicated, self-cleaning
def mount(%{"id" => id}, _session, socket) do
  auction = Auctions.get_auction!(socket.assigns.current_scope, id)

  if connected?(socket) do
    Auctions.subscribe_auction(auction)

    PaddleWeb.Presence.track(
      self(),
      "auction_watchers:#{auction.id}",
      socket.assigns.current_scope.user.id,
      %{joined_at: System.system_time(:second)}
    )
  end

  {:ok, assign(socket, :auction, auction)}
end
```

Reference: [Phoenix.Presence (process monitoring, CRDT replication, no single point of failure)](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
