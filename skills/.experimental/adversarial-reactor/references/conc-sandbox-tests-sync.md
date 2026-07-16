---
title: Disable async execution when testing reactors against the Ecto sandbox
tags: conc, testing, ecto-sandbox, async
---

## Disable async execution when testing reactors against the Ecto sandbox

Steps default to `async? true` and execute in spawned task processes. The Ecto
SQL sandbox grants its connection to the *test process* — a task process the
reactor spawns has no ownership, so a DB-touching step inside a plain
`Reactor.run(MyReactor, inputs)` raises `DBConnection.OwnershipError`, or
worse, passes and fails intermittently depending on which steps the planner
ran async. The testing guide's instruction is to disable async execution when
testing reactors that interact with databases or shared resources: pass
`async?: false` in the run options so every step runs in the test process
that owns the connection.

**Evidence of violation:** a `Reactor.run`/`Reactor.run!` call in a test file
(`test/**`), exercising a reactor whose steps touch `Repo` (directly or through
the modules they mount), without `async?: false` in the options argument.
PASS: every sandbox-backed reactor test passes `async?: false` (or the test
uses shared-mode ownership and cites it). N/A: no reactor tests in the target,
or the reactors under test perform no DB work.

```elixir
test "places an order" do
  assert {:ok, order} =
           Reactor.run(
             Checkout.PlaceOrder,
             %{cart_id: cart.id},
             %{},
             async?: false
           )
end
```

Reference: [Reactor — Testing Strategies](https://reactor.hexdocs.pm/testing-strategies.html)
