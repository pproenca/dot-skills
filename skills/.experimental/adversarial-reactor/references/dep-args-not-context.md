---
title: Pass inter-step data through arguments, never through context or shared state
tags: dep, arguments, context, data-flow
---

## Pass inter-step data through arguments, never through context or shared state

Arguments are not just parameter passing — they are how the DAG exists.
`argument :user, result(:create_user)` simultaneously delivers the value and
tells the planner "this step runs after that one". Context is the opposite: an
arbitrary caller-supplied map merged into every step for cross-cutting data
(current user, tenant, trace id) — writing to it from one step and reading it
in another creates **no edge**, so the reader can be scheduled before, or
concurrently with, the writer. The same is true of smuggling through an Agent,
ETS, or the process dictionary (which also does not cross the task-process
boundary async steps run in). The result is a race that happy-path tests pass —
the planner often happens to pick the intended order — and production
intermittently does not.

**Evidence of violation:** a step's `run` reads a key from `context` (or an
Agent/ETS table/process dictionary) that another step in the same reactor
produces, with no `argument` on the reader sourced from that producer's
`result(...)`. PASS: everything a step consumes from another step arrives via
declared arguments; context carries only caller-supplied cross-cutting values.
N/A: no step in the target consumes another step's output, or context holds
only caller-supplied data.

```elixir
step :create_user, Accounts.CreateUser do
  argument :email, input(:email)
end

step :send_welcome, Accounts.SendWelcome do
  # The value and the ordering edge, in one declaration.
  argument :user, result(:create_user)
  # Cross-cutting caller data is what context is for:
  # run(%{user: user}, %{tenant: tenant}, _opts)
end
```

Reference: [Reactor — run/4 context and argument templates](https://reactor.hexdocs.pm/Reactor.html)
