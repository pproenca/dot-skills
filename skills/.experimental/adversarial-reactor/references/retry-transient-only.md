---
title: Retry transient failures only — never business-logic failures
tags: retry, compensate, transient, idempotency
---

## Retry transient failures only — never business-logic failures

A retry re-runs `run/3` in full. For a transient fault — a timeout, a dropped
connection — that is the correct response: the operation might succeed next
time. For a deterministic business failure — a declined card, an out-of-stock
item, a validation error — it cannot succeed next time, and re-running it
re-executes a non-idempotent external operation: the declined card gets charged
again, the provider gets hammered, and when retries exhaust, the caller sees a
retries-exhausted error instead of the real domain error. The wrong default is
the catch-all clause `def compensate(_reason, _, _, _), do: :retry`, which
erases the distinction entirely.

**Evidence of violation:** a `compensate` (module callback or DSL fn) that
returns `:retry` from a clause matching a bare variable or `_` — no pattern
narrowing the reason to transient shapes. This is FAIL by default: the
catch-all is the tell, and the reviewer needs no domain knowledge of the
service's failure modes. PASS: `:retry` is returned only from clauses matching
named transient errors (timeouts, connection errors, HTTP 5xx/429), with
domain failures falling through to `:ok` or `{:error, reason}`. N/A: no
compensate in the target returns `:retry` — or the reviewer can cite evidence
that the step's failures are exclusively transient (e.g. a pure network probe
with no domain answer); an uncited assumption of transience does not excuse
the catch-all.

```elixir
@impl true
def compensate(%Payments.TimeoutError{}, _arguments, _context, _options), do: :retry
def compensate(%Payments.ConnectionError{}, _arguments, _context, _options), do: :retry
# Declined is a business answer, not a fault — retrying re-charges the card.
def compensate(%Payments.CardDeclinedError{} = reason, _args, _ctx, _opts),
  do: {:error, reason}
def compensate(_reason, _arguments, _context, _options), do: :ok
```

Reference: [Reactor — Payment Processing tutorial: retry decisions](https://reactor.hexdocs.pm/payment-processing.html)
