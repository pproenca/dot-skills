---
title: Avoid using an Agent/GenServer as a mutable variable
tags: proc, agent, ets, concurrency
---

## Avoid using an Agent/GenServer as a mutable variable

An `Agent` (or GenServer) wrapping a bare counter, list, or map so callers can read-modify-write it is a slow, serialized mutable variable. Every access is a message round-trip through one mailbox, and the read-then-write-back pattern across concurrent callers loses updates — two callers both read `5`, both write `6`, and one increment vanishes. If the value is genuinely shared mutable state, ETS gives lock-free atomic updates without a process in the hot path.

**Evidence of violation:** an `Agent` (or GenServer) whose state is a bare scalar, list, or map and whose entire interface is get/put/update pass-throughs with no domain logic in the callbacks — or any caller doing read-then-write-back across two calls (`get` then `update` with the read value), which loses updates under concurrency. PASS: shared counters/lookups live in ETS (or the value is simply passed as function arguments), and any remaining process transforms its state inside a single `handle_call`/`Agent.get_and_update`. N/A: no Agent/GenServer in the target holds bare-value state. Carve-out (in the rule): the state must be transformed under genuine serialization with custom logic (a rate limiter, a coordinator) — the callbacks must show that logic; storage alone does not qualify.

**Incorrect (lost updates + a serialization point):**

```elixir
{:ok, agent} = Agent.start_link(fn -> 0 end)
# concurrent callers:
count = Agent.get(agent, & &1)
Agent.update(agent, fn _ -> count + 1 end)   # racy read-modify-write
```

**Correct (atomic, no process to serialize on):**

```elixir
:ets.new(:hits, [:public, :named_table])
:ets.update_counter(:hits, :page_views, 1, {:page_views, 0})   # atomic increment
```

**When a process IS right:** the state must be transformed under genuine serialization with custom logic (a rate limiter, a coordinator), not merely stored. Then a GenServer's single-threaded mailbox is the feature, not the cost.

Reference: [Erlang — `ets:update_counter` performs an atomic read-modify-write](https://www.erlang.org/doc/apps/stdlib/ets.html#update_counter/3)
