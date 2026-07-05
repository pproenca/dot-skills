---
title: Drop the dependency-injection behaviour for a single implementation
tags: arch, behaviour, testability, mox
---

## Drop the dependency-injection behaviour for a single implementation

Defining a `@behaviour` and injecting the implementation module through config or opts — when there is exactly one real implementation — is enterprise DI ceremony imported to buy "testability." In Elixir you get testability from pure functions and explicit data, not from an interface seam between two of your own modules. The indirection makes every call site parameterized, hides which code actually runs, and pays for flexibility no one uses.

```elixir
# One implementation: call it directly. No behaviour, no injection.
defmodule MyApp.Orders do
  def total(order), do: MyApp.Pricing.total(order)
end
```

**When a behaviour DOES earn its place:** at a genuine external boundary you must swap in tests — a payment gateway, an SMS/email sender, a third-party HTTP client. There, define a behaviour and use `Mox` to verify interactions against a contract. The test is: does a *second* implementation genuinely exist (a fake for a network dependency)? If not, delete the seam.

Reference: [Elixir — Mox and explicit contracts for external dependencies](https://hexdocs.pm/mox/Mox.html)
