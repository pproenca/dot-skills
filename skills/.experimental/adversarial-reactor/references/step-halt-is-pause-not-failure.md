---
title: Halt is a pause with a resumable struct — never an error signal
tags: step, halt, resume, error-handling
---

## Halt is a pause with a resumable struct — never an error signal

`{:halt, reason}` from `run/3` does not abort the reactor — it *suspends* it.
No compensation or undo runs, and the caller receives `{:halted, reactor}`
holding the incomplete state for later resumption (pass the struct back to
`Reactor.run/4`; its first argument accepts a struct as well as a module).
Two wrong defaults follow from misreading halt as failure. Producing it on an
error path means completed side effects are never rolled back and the caller
never sees an error. Consuming it wrong — matching only `{:ok, _}`/`{:error,
_}` at a call site that can halt, or "resuming" by re-running the module from
scratch — crashes on the unexpected tuple or re-executes every already-completed
side effect: double charges, duplicate emails.

**Evidence of violation:** either direction — (a) a `run` that returns
`{:halt, reason}` on an exceptional/failure path (the reason is an error
value, or the surrounding clauses handle the same condition as `{:error, _}`);
(b) a `Reactor.run` call site whose reactor contains halt-capable steps but
whose result match has no `{:halted, _}` clause, or resumption code that
passes the module instead of the halted struct. PASS: halt is produced only
for intentional pause points (awaiting approval, batch windows), every
halt-capable call site matches `{:halted, reactor}`, and resumption passes the
struct. N/A: nothing in the target produces or can receive a halt.

```elixir
# Pause for human approval; resume with the saved struct, not the module.
case Reactor.run(Payments.LargeTransfer, %{transfer: transfer}) do
  {:ok, receipt} -> {:ok, receipt}
  {:halted, paused} -> PendingApprovals.save(transfer.id, paused)
  {:error, reason} -> {:error, reason}
end

# Later, after approval — completed steps are not re-executed:
{:ok, paused} = PendingApprovals.fetch(transfer_id)
Reactor.run(paused, %{}, %{})
```

Reference: [Reactor — run/4 return values and halting](https://reactor.hexdocs.pm/Reactor.html)
