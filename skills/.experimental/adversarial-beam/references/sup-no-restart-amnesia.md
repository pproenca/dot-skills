---
title: Design GenServer state to survive its own restart
tags: sup, genserver, restart, state-recovery
---

## Design GenServer state to survive its own restart

Restart works because it restores a *known good state* — but the known good state a supervisor restores is whatever `init/1` builds, which for most generated GenServers is empty. A server that accumulates business state across calls (balances, sequence counters, in-flight reservations) and starts from `%{}` has restart amnesia: after a crash it answers under the same registered name, callers proceed as if nothing happened, and the ledger is quietly gone. The supervisor healed the *process* but not the *data*. Anything not rebuildable inside `init`/`handle_continue` must live in a durable home (the database, an ETS table with an heir) that the fresh process rehydrates from.

**Evidence of violation:** a supervised GenServer whose `handle_call`/`handle_cast`/`handle_info` clauses accumulate domain state the system's correctness depends on (money, counters used as identifiers, reservations, job progress), while `init`/`handle_continue` construct the initial state from constants or arguments only — no read from a durable source, no ETS heir handoff, no rebuild. PASS: startup rehydrates from the database or an owned durable store; or the state lives in ETS with an `:heir` so the table survives the worker; or the process is `restart: :temporary`/`:transient` *and* its callers handle its absence. N/A: no GenServer accumulating cross-call state in the target. Carve-out (citable): the state is a cache or derivation that later calls rebuild on demand, or is defined-ephemeral (presence, a rate-limit window, metrics in flight) — cite what makes loss harmless; "it hasn't crashed yet" is not evidence.

```elixir
def init(account_id) do
  {:ok, %{account_id: account_id, entries: []}, {:continue, :rehydrate}}
end

def handle_continue(:rehydrate, state) do
  # A restarted process must reach the same known good state a fresh boot
  # would — rebuild it from the durable source of truth, not from %{}.
  entries = MyApp.Ledger.entries_for(state.account_id)
  {:noreply, %{state | entries: entries}}
end
```

Reference: [Fred Hébert — "The Zen of Erlang" (restarts work by restoring a known good state)](https://ferd.ca/the-zen-of-erlang.html)
