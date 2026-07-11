---
title: Never park durability in terminate/2
tags: sup, genserver, terminate, durability
---

## Never park durability in terminate/2

`terminate/2` reads like a destructor, so buffered writes get flushed there — but the callback is best-effort by contract. It is skipped when the process is `:kill`ed (which is exactly what the supervisor sends when a shutdown timeout is exceeded), when the VM halts or the node crashes, and when an exit signal arrives while the process is not trapping exits. So the flush runs on the graceful paths and silently doesn't on the violent ones — data loss that appears only during deploys, crashes, and OOM kills, never in tests. Durability needs a path that runs *during* life: write-through, a periodic flush timer, or a WAL; `terminate` may then remain as a best-effort courtesy flush.

**Evidence of violation:** a `terminate/2` that persists or transmits state accumulated across calls (writing buffered rows, flushing a batch to an external system, saving state to disk) where no other code path persists the same data — no periodic flush, no size-triggered flush, no write-through. Trapping exits does not excuse it: `Process.flag(:trap_exit, true)` widens the cases where `terminate` runs but cannot cover kills or VM death. PASS: durability has an in-life path (timer- or threshold-triggered flush, write-through to ETS with an heir, WAL) and `terminate` is absent or merely best-effort; cleanup of non-durable resources (closing sockets, deregistering) in `terminate` is fine. N/A: no `terminate/2` bodies and no cross-call state accumulation in the target. Carve-out (citable): the buffered data is explicitly acceptable to lose — a metrics batch, a log buffer — cite the comment or the data's nature making loss tolerable.

```elixir
def init(opts) do
  flush_every = Keyword.fetch!(opts, :flush_interval_ms)
  :timer.send_interval(flush_every, :flush)
  {:ok, %{buffer: [], flush_every: flush_every}}
end

def handle_info(:flush, %{buffer: []} = state), do: {:noreply, state}

def handle_info(:flush, state) do
  # Durability happens on a timer while the process lives — a kill between
  # ticks loses at most one interval, and that bound is a design decision.
  :ok = MyApp.Ledger.persist_batch(state.buffer)
  {:noreply, %{state | buffer: []}}
end
```

Reference: [Elixir `GenServer` — `terminate/2` ("not called if the process exits abnormally... or is killed")](https://hexdocs.pm/elixir/GenServer.html#c:terminate/2)
