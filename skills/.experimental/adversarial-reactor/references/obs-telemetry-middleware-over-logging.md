---
title: Use the Telemetry middleware for lifecycle observability, not Logger calls in steps
tags: obs, telemetry, middleware, logging
---

## Use the Telemetry middleware for lifecycle observability, not Logger calls in steps

Sprinkling `Logger.info("charging payment...")` and hand-rolled duration
timing through step bodies rebuilds, inconsistently, a fraction of what
`Reactor.Middleware.Telemetry` already emits: start/stop events for the run
and for every step's run, guard, process, compensate, and undo phases —
with durations, as measurable `:telemetry` events any handler can consume.
The hand-rolled version instruments only the steps someone remembered, sees
nothing of compensation or undo (the phases that matter most in an incident),
and couples every step body to a logging policy. Attach the middleware once
in a `middlewares` block; extra dimensions ride along via the
`telemetry_metadata` context key.

**Evidence of violation:** started/finished/duration logging (or manual
`System.monotonic_time` timing) inside two or more step bodies, in a reactor
with no `middlewares` section attaching `Reactor.Middleware.Telemetry` (or an
equivalent custom middleware). PASS: lifecycle observability comes from
middleware; in-step logging is limited to domain events ("refund exceeds
threshold"), not step lifecycle. N/A: the target has no lifecycle logging in
steps and no observability requirement in evidence.

```elixir
defmodule Checkout.PlaceOrder do
  use Reactor

  middlewares do
    middleware Reactor.Middleware.Telemetry
  end

  # Steps stay free of lifecycle logging; handlers subscribe to
  # [:reactor, :step, :run, :stop] and friends instead.
end
```

Reference: [Reactor.Middleware.Telemetry](https://reactor.hexdocs.pm/Reactor.Middleware.Telemetry.html)
