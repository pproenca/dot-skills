---
title: Set max_retries on any step whose compensate can return :retry
tags: retry, max-retries, compensate, termination
---

## Set max_retries on any step whose compensate can return :retry

The DSL default is `max_retries :infinity`. That default is safe only because
steps without a retrying compensate never exercise it — the moment a
`compensate` can return `:retry` (or `{:retry, reason}`), the unstated default
becomes "retry this step forever". On a permanent failure — a bad request, a
revoked credential, a bug — the reactor never terminates and never rolls back;
it just spins. The docs' own guidance: always set `max_retries` and ensure
compensation doesn't always return `:retry`. A retry policy without a bound is
not a policy.

**Evidence of violation:** a step whose `compensate` (module callback or DSL
fn) contains a `:retry`/`{:retry, _}` return, and whose DSL step block has no
`max_retries` line (module-based steps get the same `:infinity` default from
the `step` entity that mounts them). PASS: every step with a retrying
compensate carries an explicit `max_retries n`. N/A: no compensate in the
target returns `:retry`.

```elixir
step :charge_payment, Checkout.ChargePayment do
  argument :order, result(:create_order)
  # ChargePayment.compensate/4 returns :retry on timeouts —
  # bound it, or a permanent failure retries forever.
  max_retries 3
end
```

Reference: [Reactor DSL — step options, max_retries default](https://reactor.hexdocs.pm/dsl-reactor.html)
