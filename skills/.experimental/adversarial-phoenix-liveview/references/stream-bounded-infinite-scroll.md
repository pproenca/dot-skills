---
title: Bound viewport pagination with stream limit, end guard, and overran reset
tags: stream, infinite-scroll, phx-viewport, pagination, memory
---

## Bound viewport pagination with stream limit, end guard, and overran reset

`phx-viewport-top`/`phx-viewport-bottom` make infinite scroll one binding away, and every piece of the documented pattern that gets dropped turns it into a leak or a loop. Without `phx-update="stream"` the paginated rows accumulate in assigns; without `limit:` on the stream calls the *DOM* grows without bound even though the server holds nothing; without an end-of-collection guard the bottom binding refires forever once the data runs out; and without handling the `"_overran" => true` param, a user who yanks the scrollbar past the pruned window strands the view with no way back to a consistent page. The four legs are one pattern — the docs present them together because each one covers a failure the others create.

**Evidence of violation:** any `phx-viewport-top` or `phx-viewport-bottom` binding in the target activates all four legs, and each missing leg is a FAIL naming that leg: (1) the bound container lacks `phx-update="stream"`; (2) the `stream`/`stream_insert` calls feeding it carry no `limit:`; (3) the binding is unguarded — no end-of-collection assign gating it (`phx-viewport-bottom={!@end_of_timeline? && JS.push("next-page")}`); (4) the paging event handler has no clause for `%{"_overran" => true}` resetting to the first page. PASS: all four legs present. N/A: no viewport bindings in the target. Carve-out (citable): a genuinely finite, small collection paginated for layout rather than scale excuses the `_overran` clause only when the stream is created with `reset: true` on every page change and the code shows the total bound — cite both; absence of evidence about collection size fails closed.

```elixir
def handle_event("next-page", %{"_overran" => true}, socket) do
  {:noreply, paginate_lots(socket, 1)}
end

def handle_event("next-page", _params, socket) do
  {:noreply, paginate_lots(socket, socket.assigns.page + 1)}
end

defp paginate_lots(socket, page) do
  lots = Paddle.Catalog.list_lots(socket.assigns.current_scope, page: page)

  socket
  |> assign(page: page, end_of_catalog?: lots == [])
  |> stream(:lots, lots, at: -1, limit: 60)
end
```

```heex
<div id="lots" phx-update="stream"
     phx-viewport-bottom={!@end_of_catalog? && JS.push("next-page", page_loading: true)}>
  <.lot_card :for={{dom_id, lot} <- @streams.lots} id={dom_id} lot={lot} />
</div>
```

Reference: [Bindings — scroll events and infinite pagination — hexdocs](https://hexdocs.pm/phoenix_live_view/bindings.html#scroll-events-and-infinite-pagination)
