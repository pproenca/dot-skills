---
title: Honor the stream DOM contract of container id plus stream-issued item ids
tags: stream, dom-patching, phx-update, ids
---

## Honor the stream DOM contract of container id plus stream-issued item ids

Streams keep no server-side copy of the collection, so the DOM itself is the state — and LiveView can only patch state it can address. That addressing is a three-part contract: the container carries `phx-update="stream"`, the container carries a DOM `id`, and every child's `id` is the stream-issued dom_id from the `{dom_id, item}` tuples that `@streams.name` yields. Break any part and patching degrades silently: inserts land in the wrong place or duplicate, `stream_delete` cannot find its row, and a hand-built or index-based id stops matching the moment the collection reorders. Nothing raises; the UI just drifts from the data.

**Evidence of violation:** a template consuming `@streams.anything` where the comprehension's container lacks a DOM `id` or lacks `phx-update="stream"`; child elements whose `id` is hand-built (`id={"bid-#{bid.id}"}`), index-based, or absent instead of the first element of the `{dom_id, item}` tuple; or a `stream_delete`/`stream_insert` targeting items whose rendered ids were never the stream's dom_ids. PASS: every streamed container shows all three parts — container `id`, `phx-update="stream"`, and `:for={{dom_id, item} <- @streams.name}` with `id={dom_id}` on the child. N/A: the target renders no streams. Carve-out (citable): a custom dom_id is legitimate only when configured server-side via the `stream/4` `:dom_id` option so client and server agree — cite the `dom_id:` option at the stream call; a template-side rewrite of the id is never excused.

```heex
<ul id="bids" phx-update="stream">
  <li :for={{dom_id, bid} <- @streams.bids} id={dom_id}>
    {bid.bidder_handle} bid {bid.amount}
  </li>
</ul>
```

Reference: [Phoenix.LiveView — streams — hexdocs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#stream/4)
