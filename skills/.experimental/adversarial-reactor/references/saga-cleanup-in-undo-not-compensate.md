---
title: Put cleanup in undo, not compensate — they fire on different failures
tags: saga, compensate, undo, callbacks
---

## Put cleanup in undo, not compensate — they fire on different failures

The two rollback callbacks answer different questions. `compensate(reason,
arguments, context, options)` runs when **this step's own `run` failed** and
receives the *error reason* — the step's result does not exist yet, so there is
nothing to clean up. `undo(value, arguments, context, options)` runs when **this
step succeeded but a later step failed** and receives the *successful result*.
The wrong default is writing "delete what I created" inside `compensate`,
expecting it to fire when a downstream step fails — it never will, because
compensate only runs before the side effect committed. The mirror error is
signature confusion: pattern-matching an error struct in `undo`'s first
parameter (it gets the success value) or the result shape in `compensate`'s
(it gets the reason), which crashes the rollback itself.

**Evidence of violation:** a `compensate/4` body (or DSL `compensate` fn) that
deletes, voids, or releases the resource its own `run` creates — with no
`undo/4` carrying that cleanup; or a first parameter pattern that contradicts
the contract: `undo` matching error shapes (`%SomeError{}`, `{:error, _}`), or
`compensate` matching the step's success-value shape. PASS: cleanup of
successful work lives in `undo/4`; `compensate` handles only its own failure
(retry decisions, `{:continue, fallback}`, error enrichment). N/A: the target
defines neither callback on any step.

```elixir
defmodule Checkout.AuthorizePayment do
  use Reactor.Step

  @impl true
  def run(%{order: order}, _context, _options) do
    Payments.authorize(order.total, order.payment_method)
  end

  # Own failure: decide retry vs give up. The authorization never happened.
  @impl true
  def compensate(%Payments.TimeoutError{}, _arguments, _context, _options), do: :retry
  def compensate(_reason, _arguments, _context, _options), do: :ok

  # Downstream failure: the authorization exists and must be voided.
  @impl true
  def undo(authorization, _arguments, _context, _options) do
    Payments.void(authorization)
  end
end
```

Reference: [Reactor.Step — compensate/4 and undo/4 contracts](https://reactor.hexdocs.pm/Reactor.Step.html)
