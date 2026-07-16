---
title: Implement side-effecting steps as Reactor.Step modules, not inline anonymous functions
tags: step, modules, testability, anonymous-functions
---

## Implement side-effecting steps as Reactor.Step modules, not inline anonymous functions

Inline `run fn` steps are the low-friction default, and for pure transforms
they are fine. For a step that touches the outside world they quietly cost the
saga its machinery: an anonymous function cannot be unit-tested or mocked
(Mimic and friends copy *modules*), cannot implement `backoff/4` as a
behaviour callback, and cannot answer capability queries (`can?/2`) — while a
module step holds `run`, `compensate`, `undo`, and `backoff` together as one
reviewable, reusable unit. The DSL does accept inline `compensate`/`undo`
functions, so this is not about possibility — it is that side-effecting logic
buried in a DSL block ends up tested only through the whole reactor and
reused by copy-paste.

**Evidence of violation:** a DSL `step` whose inline `run fn` performs an
externally-visible write (Repo write, HTTP call, payment/reservation call,
file write, message publish) instead of mounting a `Reactor.Step` module.
PASS: every side-effecting step names a module; inline fns are confined to
pure transforms and lookups. N/A: no inline `run fn` performs a side effect
in the target.

```elixir
# Pure glue: inline is the right size.
step :normalize_email do
  argument :email, input(:email)
  run fn %{email: email}, _ctx -> {:ok, String.downcase(email)} end
end

# Side effect: a module owns run + compensate + undo + backoff together.
step :charge_payment, Checkout.ChargePayment do
  argument :order, result(:create_order)
  max_retries 3
end
```

Reference: [Reactor — Testing Strategies: step modules over inline functions](https://reactor.hexdocs.pm/testing-strategies.html)
