---
title: Use JS commands for pure presentation toggles
tags: ui, js-commands, latency, round-trip
---

## Use JS commands for pure presentation toggles

A `handle_event` that only flips a presentation assign — a boolean rendered as show/hide or a class switch — routes a dropdown open through the server: client → websocket → GenServer → diff → patch, paying the user's full round-trip latency for state the server never uses. `Phoenix.LiveView.JS` commands (`JS.toggle`, `JS.toggle_class`, `JS.toggle_attribute`, `JS.show`/`JS.hide`) execute the same mutation client-side at zero latency, and they are DOM-patch aware, so the toggled state sticks across server patches. When a server effect genuinely accompanies the interaction, pipe it — `JS.push("track") |> JS.toggle(...)` — which is the LiveBeats optimistic pattern: instant feedback, server reconciles.

**Evidence of violation:** a `handle_event` clause whose body performs no side effect and assigns only state that the template consumes exclusively for visibility or classes (`:if`, `hidden`, class interpolation) — trace every read of the assign; if all reads are presentational, the round-trip is the violation. PASS: the binding uses a JS command (`phx-click={JS.toggle(to: "#filter-drawer")}`), with or without a piped `JS.push` for a real server effect. N/A: no presentation-only event handlers in the target. Carve-out (citable): the assign is read by server logic — another `handle_event`, a query, a `handle_info` branch — or is deliberately restored on reconnect; cite the specific read site, otherwise fail closed.

```heex
<button phx-click={JS.toggle(to: "#filter-drawer") |> JS.toggle_class("rotate-180", to: "#drawer-chevron")}>
  Filters
</button>
<div id="filter-drawer" class="hidden">
  <!-- lot filters; open/closed state never consulted by the server -->
</div>
```

Reference: [Phoenix.LiveView.JS](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.JS.html)
