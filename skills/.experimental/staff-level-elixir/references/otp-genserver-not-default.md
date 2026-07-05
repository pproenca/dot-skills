---
title: Avoid reaching for a GenServer as the default abstraction
tags: otp, genserver, process, state
---

## Avoid reaching for a GenServer as the default abstraction

The common wrong default is to wrap any stateful-sounding logic in a GenServer. A GenServer processes its mailbox one message at a time, so every caller serializes through it — that is the right tool only when you genuinely need serialized access to mutable state or a long-lived owner of a resource (a connection, a socket, a rate limiter). Pure transformation needs no process at all; one-off concurrent work is a `Task`; shared read-heavy state is ETS; simple wrapped state with no custom logic is `Agent`. Modelling a stateless calculation as a GenServer turns a parallelizable function into a single-threaded bottleneck and adds supervision, message-passing, and copying overhead for nothing.

```elixir
# A price calculator has no state to own — it's a pure function.
# Callers run it concurrently on their own schedulers; no process needed.
defmodule Billing.PriceCalculator do
  def total(line_items, tax_rate) do
    subtotal = Enum.reduce(line_items, 0, &(&1.amount + &2))
    subtotal + round(subtotal * tax_rate)
  end
end

# Reserve a GenServer for genuine serialized ownership — e.g. a token-bucket
# rate limiter whose counter must be mutated atomically by concurrent callers.
defmodule PaymentGateway.RateLimiter do
  use GenServer
  # ... init/handle_call that decrements a shared budget under serialization
end
```

Reference: [Elixir — Process anti-patterns: "Code organization by process"](https://hexdocs.pm/elixir/process-anti-patterns.html)
