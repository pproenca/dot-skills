---
title: Treat call timeouts as contracts — never silence or blind-retry them
tags: load, genserver, timeout, idempotency
---

## Treat call timeouts as contracts — never silence or blind-retry them

A `GenServer.call` timeout does not cancel anything: the server keeps processing the request, and the caller merely stops waiting (the late reply is dropped by the caller's exit or ignored). Two reflexes make this worse. Passing `:infinity` to make timeout crashes go away removes the only signal that a server is overloaded or deadlocked — the caller now hangs forever instead of failing loudly. And `catch :exit` followed by a retry double-submits: the first request is still in the mailbox or mid-flight, so retrying a non-idempotent operation (a charge, an append, a counter bump) executes it twice. A timeout is the contract "I waited this long"; what follows must be a decision — propagate the failure, shed, or retry an operation that is provably safe to repeat.

**Evidence of violation:** any of three shapes — (1) `catch :exit` (or `try/catch` on `:exit`) around a `GenServer.call` followed by a retry of the same non-idempotent operation with no dedup key or server-side guard; (2) `:infinity` passed as the timeout of a call into a server that performs external IO or takes externally-driven traffic, with no citable justification; (3) an outer `call` with a shorter timeout wrapping an inner `call` with a longer or default one, so the inner work is guaranteed to outlive the outer contract. PASS: timeouts explicit and shrinking with depth; timeout handling that propagates or sheds; retries only of operations made idempotent (and the mechanism cited). N/A: no `GenServer.call` in the target. Carve-out (citable): `:infinity` toward a local, pure-computation server invoked during startup or a migration, where unbounded waiting is the stated intent — cite it.

```elixir
# The operation carries a request id, so the server can dedupe — only then
# is retry-after-timeout safe. Without the id, the timeout must propagate.
def reserve(sku, qty, request_id) do
  GenServer.call(via(sku), {:reserve, qty, request_id}, 2_000)
catch
  :exit, {:timeout, _} ->
    GenServer.call(via(sku), {:reserve, qty, request_id}, 2_000)
end
```

Reference: [Elixir `GenServer.call/3` — timeout semantics and late replies](https://hexdocs.pm/elixir/GenServer.html#call/3)
