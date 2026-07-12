---
title: Render collections with keyed :for, not Enum.map
tags: render, comprehensions, keyed, diffs
---

## Render collections with keyed :for, not Enum.map

Comprehensions are the one collection construct HEEx optimizes: the guide's comprehension section documents that "the static parts of a comprehension are only sent once, regardless of the number of items," and that with a `:key` "if only a single entry in @posts changes, only this entry is sent again" (default tracking is by index, so a prepend or re-sort re-sends everything after the insertion point). Markup built through `Enum.map` inside the template is an ordinary dynamic expression outside that machinery — to be precise, the guide never prohibits `Enum.map`; the cost is inferred from what comprehension optimization stops applying to. Nothing breaks; the whole rendered list re-ships whenever the collection changes, which on a realtime bid feed is the difference between a one-row diff and the full table per bid. Use `:for` on the element, and add `:key={item.id}` when items carry identity and the list reorders or inserts mid-list.

**Evidence of violation:** HEEx interpolating `Enum.map(@collection, fn ...)` (or `Enum.with_index` and friends) to produce elements; or a `:for` over id-bearing structs without `:key` in a LiveView whose handlers demonstrably reorder, re-sort, or prepend that list — cite the handler that mutates the order. PASS: collections render via `:for`, with `:key` where identity plus reordering are both present. N/A: the target renders no collections. Carve-outs (citable): `:key` is not supported on slots — a slot-level comprehension without it passes, cite the slot; a genuine data transformation (grouping, chunking) belongs in an assign, and citing the precomputed assign that feeds a plain `:for` passes.

```heex
<div :for={bid <- @recent_bids} :key={bid.id} class="flex justify-between">
  <span>{bid.bidder_handle}</span>
  <span>{format_amount(bid.amount)}</span>
</div>
```

Reference: [Assigns and HEEx templates — Comprehensions](https://hexdocs.pm/phoenix_live_view/assigns-eex.html)
