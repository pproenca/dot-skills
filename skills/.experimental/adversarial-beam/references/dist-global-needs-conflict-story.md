---
title: Give every :global singleton a netsplit story
tags: dist, global, netsplit, singleton
---

## Give every :global singleton a netsplit story

`{:global, name}` reads like a distributed lock: "one process per cluster, the runtime enforces it." It does not. During a partition each side of the split can register and run its own copy — two singletons performing the same writes — and on heal `:global` resolves the duplicate with its default method, which *terminates one of the two at random*, discarding whatever in-memory state and in-flight work it held. (Newer OTP releases avoid *overlapping* partitions by disconnecting nodes more aggressively, which narrows but does not remove the window, and adds its own failure mode: more frequent full disconnects.) So a `:global` name is a convenience for locating a process, not a correctness mechanism. A singleton whose duplicate execution corrupts state needs fencing that lives outside the cluster's own view of itself: a database lock or lease, unique job execution, or downstream idempotency that absorbs the duplicate.

**Evidence of violation:** a process registered via `:global.register_name`, `name: {:global, ...}`, or `{:via, :global, ...}` that performs non-idempotent effects (writes, charges, external calls), with the default conflict resolution and no fencing mechanism — no database advisory lock or lease guarding the effect, no unique-execution guard, no downstream idempotency the reviewer can cite. PASS: the effect path is fenced (lease/lock checked before acting, effects idempotent by key); or a custom resolve function plus a documented recovery for the killed instance's state; or the globally-named process is read-only/advisory (a locator, a coordinator whose decisions are re-derivable). N/A: no `:global` registration in the target — and this whole category is N/A when the application demonstrably never clusters. Carve-out (citable): duplicates are tolerable for the stated window because the work is reconciled later — cite the reconciler.

```elixir
# The name locates the scheduler; the *lease* makes it safe. A partitioned
# twin fails to acquire the lease and stands down instead of double-running.
def handle_info(:run_billing, state) do
  case MyApp.Leases.acquire(:billing_runner, ttl_ms: 60_000) do
    {:ok, lease} -> run_billing_cycle(lease)
    {:error, :held} -> :ok
  end

  schedule_next_run()
  {:noreply, state}
end
```

Reference: [Erlang `global` — name registration and conflict resolution](https://www.erlang.org/doc/apps/kernel/global.html)
