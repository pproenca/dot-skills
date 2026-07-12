---
title: Pass explicit assigns, not the assigns map
tags: render, change-tracking, function-components, heex
---

## Pass explicit assigns, not the assigns map

Change tracking works by recording which `@field`s each component and helper actually uses; that record is built from what you pass at the call site. Hand the whole map over — `{bid_summary(assigns)}`, or `<.bid_row {assigns} />` — and the engine has one answer for "what does this depend on": everything. The guide states such code "will not perform change tracking and it will always re-render" every affected component; on a realtime screen that means each watcher-count tick re-ships every row of the auction table. Call function components with named attrs and helpers with the specific values they need, so each subtree re-renders only when its own inputs change.

**Evidence of violation:** a helper invoked with the full map in template position (`{render_watchers(assigns)}`); a function component call spreading the whole map (`<.auction_card {assigns} />`); a private function taking `assigns` and reaching into fields the caller never explicitly passed. PASS: component calls use named attrs (`bid={bid}`, `count={@watcher_count}`) and helpers take scalars or structs — cite representative call sites. N/A: the target's templates call no components or helpers. Carve-out (citable): spreading a declared globals attr — `{@rest}` backed by `attr :rest, :global` — is the documented pass-through mechanism, not map passing; cite the `attr` declaration.

```heex
<.bid_row
  :for={{dom_id, bid} <- @streams.bids}
  id={dom_id}
  bid={bid}
  leading?={bid.id == @leading_bid_id}
/>
```

Reference: [Assigns and HEEx templates — The assigns variable](https://hexdocs.pm/phoenix_live_view/assigns-eex.html)
