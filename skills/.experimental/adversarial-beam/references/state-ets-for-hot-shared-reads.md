---
title: Serve hot shared reads from ETS, not a GenServer reply
tags: state, ets, genserver, read-concurrency
---

## Serve hot shared reads from ETS, not a GenServer reply

A GenServer holding a lookup table feels tidy — state with an API — but a GenServer processes one message at a time, so every `call` that merely *reads* the state queues behind every other reader and writer in one mailbox. Put that call on the request path and the whole node's throughput funnels through a single process: readers that could run in parallel on every scheduler instead wait in line for data none of them is mutating. ETS exists for exactly this shape — a `read_concurrency: true` table gives all schedulers parallel lock-cheap reads — with the standard split: the GenServer *owns and writes* the table, everyone else reads it directly.

**Evidence of violation:** a `GenServer.call` whose handler clause only reads state (returns a value derived from state with no state mutation in that clause), invoked from request-scoped code — controllers, plugs, LiveView `handle_event`/`handle_params`, channel handlers, or per-message job code. PASS: reads go to a public/protected ETS table (owner still a process); near-static data reads via `:persistent_term.get`; or the read genuinely requires serialization against in-flight writes — the reviewer must cite the invariant that makes a stale read incorrect, not merely note that writes exist. N/A: no shared-state reads on a hot path in the target. Carve-out (citable): the caller population is provably one process, or the call rate is structurally bounded (a periodic tick, an admin endpoint) — cite the bound; "traffic is low right now" is not structural.

```elixir
# The owner serializes writes; reads never enter its mailbox.
def init(_) do
  table = :ets.new(:feature_flags, [:named_table, :protected, read_concurrency: true])
  {:ok, %{table: table}, {:continue, :load}}
end

# Called from plugs/LiveViews on every request — parallel on all schedulers.
def enabled?(flag) do
  match?([{^flag, true}], :ets.lookup(:feature_flags, flag))
end
```

Reference: [Elixir Guide — "Speeding up with ETS" (Mix and OTP)](https://hexdocs.pm/elixir/erlang-term-storage.html)
