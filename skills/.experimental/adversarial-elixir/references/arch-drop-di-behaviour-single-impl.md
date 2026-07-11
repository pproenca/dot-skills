---
title: Drop the dependency-injection behaviour for a single implementation
tags: arch, behaviour, testability, mox
---

## Drop the dependency-injection behaviour for a single implementation

Defining a `@behaviour` and injecting the implementation module through config or opts — when there is exactly one real implementation — is enterprise DI ceremony imported to buy "testability." In Elixir you get testability from pure functions and explicit data, not from an interface seam between two of your own modules. The indirection makes every call site parameterized, hides which code actually runs, and pays for flexibility no one uses.

**Evidence of violation:** a `@behaviour`/`defmodule ... @callback` contract defined in the target whose implementation is resolved indirectly — `Application.get_env`/`compile_env`, a module passed through opts, or a `@impl_module` attribute — where a repo-wide search finds exactly one module declaring `@behaviour ThatContract` (this rule requires searching beyond the diff; the repo root is stated in the review target). PASS: call sites name the implementing module directly, or two or more real implementations exist. N/A: the target defines no behaviours. Carve-out (citable): the behaviour fronts an external dependency (network, third-party service, hardware) and a test double exists for it (a `Mox.defmock` or hand-written test impl you can point at) — cite both the boundary and the double. Behaviours implemented only by the module that defines them (callback contracts for `use`-style extension points consumed by library users) are out of this rule's scope. A carve-out asserted without citable evidence fails closed.

```elixir
# One implementation: call it directly. No behaviour, no injection.
defmodule MyApp.Orders do
  def total(order), do: MyApp.Pricing.total(order)
end
```

**When a behaviour DOES earn its place:** at a genuine external boundary you must swap in tests — a payment gateway, an SMS/email sender, a third-party HTTP client. There, define a behaviour and use `Mox` to verify interactions against a contract. The test is: does a *second* implementation genuinely exist (a fake for a network dependency)? If not, delete the seam.

Reference: [Elixir — Mox and explicit contracts for external dependencies](https://hexdocs.pm/mox/Mox.html)
