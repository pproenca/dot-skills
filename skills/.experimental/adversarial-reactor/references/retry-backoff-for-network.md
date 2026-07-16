---
title: Implement backoff/4 when retrying network failures — the default is immediate
tags: retry, backoff, network, throttling
---

## Implement backoff/4 when retrying network failures — the default is immediate

Reactor's default retry delay is `:now`. A step that returns `:retry` for a
timeout without implementing `backoff/4` re-fires instantly against the very
dependency that just proved slow or down — a hot loop that burns its whole
`max_retries` budget inside milliseconds and adds load to a degraded service
instead of riding out the blip. The `backoff/4` callback (or the DSL `backoff`
option) returns the minimum milliseconds to wait before the retry; for network
failures a growing delay is the difference between "recovered on attempt 3"
and "exhausted before the failover finished".

**Evidence of violation:** a step that returns `:retry`/`{:retry, _}` for
timeout/network/5xx error shapes (in `compensate` or `run`), with no
`def backoff` in the step module and no `backoff` option on the DSL step.
PASS: every network-retrying step defines a backoff returning a positive
delay (fixed or growing). N/A: no step retries network-shaped failures.
Carve-out (citable): the retried operation is local and cheap (an
`:ets`/in-process race, not an external call) where immediate retry is the
point — cite the operation.

```elixir
defmodule Sync.PushToWarehouse do
  use Reactor.Step

  @impl true
  def run(%{batch: batch}, _context, _options), do: Warehouse.push(batch)

  @impl true
  def compensate(%Warehouse.TimeoutError{}, _args, _ctx, _opts), do: :retry
  def compensate(_reason, _args, _ctx, _opts), do: :ok

  # Minimum pause before the retry — without this, the default is :now
  # and the whole max_retries budget burns in milliseconds.
  @impl true
  def backoff(_reason, _arguments, _context, _options) do
    :timer.seconds(2)
  end
end
```

Reference: [Reactor.Step — backoff/4](https://reactor.hexdocs.pm/Reactor.Step.html)
