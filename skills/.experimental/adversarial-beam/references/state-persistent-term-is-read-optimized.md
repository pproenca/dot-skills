---
title: Reserve persistent_term for data that changes at deploy cadence
tags: state, persistentterm, gc, config
---

## Reserve persistent_term for data that changes at deploy cadence

`:persistent_term` reads are the fastest shared reads on the VM — no copying, no locks — which tempts using it as a general key-value store. The price is on the other side: `put` and `erase` trigger a scan of *every process on the node* (a global GC pass) to find and copy any references to the old term. One `put` per request or per event converts a per-process cost into a whole-VM stall, repeatedly, and the pause grows with the process count — the busier the node, the worse the write. The module's own documentation says it plainly: persistent_term is for terms written rarely (startup, config reload) and read constantly. Anything that changes at runtime cadence belongs in ETS.

**Evidence of violation:** a `:persistent_term.put/2` or `:persistent_term.erase/1` in code that executes per request, per message, or per periodic tick — a `handle_call`/`handle_cast`/`handle_info` body, a controller/LiveView action, a worker `perform`, a poller loop. PASS: puts confined to `Application.start`, a release task, or an explicit config-reload path invoked by an operator or deployment; runtime-changing values stored in ETS with `read_concurrency`. N/A: no `:persistent_term` use in the target. Carve-out (citable): the put is in a rare, operator-triggered path that merely *looks* periodic (a code-upgrade hook, a feature-flag sync running at deploy cadence) — cite the trigger and its frequency bound.

```elixir
# Written once at boot from validated config; read on every request
# with zero copying. Anything mutable at runtime goes to ETS instead.
def start(_type, _args) do
  :persistent_term.put({MyApp, :routing_table}, MyApp.Routing.compile!())
  Supervisor.start_link(children(), strategy: :one_for_one, name: MyApp.Supervisor)
end
```

Reference: [Erlang `persistent_term` — costs of `put`/`erase`](https://www.erlang.org/doc/apps/erts/persistent_term.html)
