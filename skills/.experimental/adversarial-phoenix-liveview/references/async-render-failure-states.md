---
title: Render loading and failed states, not only ok
tags: async, async-result, error-states, loading
---

## Render loading and failed states, not only ok

`assign_async` wraps the assign in an `AsyncResult` precisely because the value has three states, and a template that renders only the ok branch makes two of them invisible: a blank region while loading, and — worse — a blank region forever after a failure. The carrier API going down becomes silent missing UI with no error and no retry affordance. `<.async_result>` exists to make the three states declarative with `:loading` and `:failed` slots. The same wrong default appears on the `start_async` side as a `handle_async/3` that matches only `{:ok, result}` — the task crashing produces an unhandled `{:exit, reason}` instead of feedback.

**Evidence of violation:** (a) an assign created by `assign_async` rendered with no `<.async_result>` wrapper and no explicit branch on its `.loading`/`.failed` states anywhere it appears; (b) a `start_async` whose `handle_async/3` clauses match only `{:ok, _}` with no `{:exit, _}` clause. PASS: `<.async_result>` with both a `:loading` and a `:failed` slot (or equivalent explicit branches over the `AsyncResult` states), and an `{:exit, _}` clause for every `start_async` name. N/A: no `assign_async`/`start_async` in the target. Carve-out (citable): a deliberately fire-and-forget `start_async` passes only when the `{:exit, _}` clause exists and states the intent in code (a comment or a telemetry/log emission inside it) — the clause being absent never passes.

```heex
<.async_result :let={quote} assign={@shipping_quote}>
  <:loading><span class="skeleton h-4 w-28"></span></:loading>
  <:failed :let={_reason}>
    <p role="alert">
      Shipping quote unavailable.
      <button phx-click="retry_quote">Retry</button>
    </p>
  </:failed>
  {quote.carrier} — {quote.price}
</.async_result>
```

Reference: [Phoenix.Component.async_result/1](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#async_result/1)
