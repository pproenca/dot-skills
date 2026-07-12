---
title: Wire every stateful form for reconnect recovery
tags: state, forms, recovery, phx-change, reconnect
---

## Wire every stateful form for reconnect recovery

LiveView sockets drop — deploys, network blips, sleeping laptops — and the client reconnects to a freshly mounted process whose form state is gone. Recovery is built in, but only under a contract: a form with both an `id` and a `phx-change` binding has its last change event replayed "as soon as the mount has been completed", restoring what the user typed. Omit either attribute and reconnection silently wipes the user's half-written input — the one failure mode a realtime UI must never have, and one that never shows up on localhost where the socket never drops. Multi-step wizards break the default replay (the last change event belongs to a step that no longer renders) and need an explicit `phx-auto-recover` handler.

**Evidence of violation:** a form that collects user-typed input (text, textarea, select, rich content) and submits via `phx-submit`, missing a DOM `id` or missing `phx-change` — auto-recovery is disabled for it. Second leg: a multi-step form (inputs rendered conditionally on a step/stage assign) relying on default recovery instead of naming a `phx-auto-recover` event. PASS: `id` + `phx-change` present on every stateful form; wizards name `phx-auto-recover`. N/A: the target renders no forms with user-typed input (button-only or toggle-only interactions). Carve-out (citable): `phx-auto-recover="ignore"` on forms whose loss is deliberate (a search box) — the attribute itself is the citation; its absence plus a missing contract is a FAIL.

```heex
<.form for={@form} id="bid-form" phx-change="validate" phx-submit="place_bid">
  <.input field={@form[:amount]} type="number" label="Your bid" />
  <.input field={@form[:note]} type="textarea" label="Note to seller" />
  <button phx-disable-with="Placing...">Place bid</button>
</.form>
```

Reference: [Phoenix.LiveView — Form bindings, Recovery following crashes or disconnects](https://hexdocs.pm/phoenix_live_view/form-bindings.html)
