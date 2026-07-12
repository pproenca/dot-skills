---
title: Load data in callbacks, never in the template
tags: render, change-tracking, data-loading, heex
---

## Load data in callbacks, never in the template

HEEx compiles every template into a change-tracked diff: a dynamic expression re-executes only when an assign it references changes. A query embedded in the template — `{Auctions.count_live()}` — references no assign, so after the first render LiveView has no reason to ever run it again; the guide is explicit that Phoenix "will never re-render the section above, even if the number of users in the database changes," and that "data loading should never happen inside the template." The result is a value frozen at mount time that looks correct in dev (the first render is right) and silently goes stale in production. Load in `mount`/`handle_params`/`handle_event`/`handle_info`, assign, and let the template render assigns only.

**Evidence of violation:** a `Repo` call, context function performing a read, or any query/external fetch invoked inside a `~H` sigil, an `.html.heex` file, or the body of `render/1` — e.g. `{Auctions.count_live()}` or `<%= Bids.recent(@auction.id) %>` in template position. PASS: every dynamic template expression references assigns (or pure functions of assigns) populated in lifecycle callbacks — cite the callback that owns each load. N/A: the target contains no HEEx templates. Carve-out (citable): pure presentation helpers over already-assigned data — formatting money, truncating text, computing a CSS class from an assign — cite that the function's arguments all derive from assigns and its body performs no read.

```elixir
def mount(_params, _session, socket) do
  socket = assign(socket, :live_count, Auctions.count_live(socket.assigns.current_scope))
  {:ok, socket}
end

# The count changes when the context broadcasts, not when the template feels like asking.
def handle_info({:auction_opened, _id}, socket) do
  {:noreply, update(socket, :live_count, &(&1 + 1))}
end
```

Reference: [Assigns and HEEx templates — Change tracking](https://hexdocs.pm/phoenix_live_view/assigns-eex.html)
