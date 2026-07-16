# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance** —
the orchestration mistakes with the widest blast radius go first; the verdict
report's fix list follows this order.

This is a pass/fail review gate, not a performance skill, so there are no impact
tiers. Each rule names a wrong assumption about Reactor's execution, dependency,
and rollback model — assumptions the code compiles cleanly with and happy-path
tests never expose — and carries an **Evidence of violation** paragraph: the
artifact evidence that decides PASS/FAIL/N/A, with carve-outs that must be
claimed with citable evidence (fail closed otherwise).

---

## 1. Saga Compensation & Undo (saga)

**Description:** Rollback treated as something Reactor does for free. Reactor
only reverses what steps teach it to reverse: `undo/4` runs when *this step
succeeded but a later one failed*; `compensate/4` runs when *this step itself
failed* and receives the error, not the result. Cleanup parked in the wrong
callback never fires, side effects without `undo` are orphaned by rollback,
`:ok` from compensate still triggers rollback (only `{:continue, value}` absorbs
the error), and undo that cannot tolerate re-execution breaks the saga exactly
when it is needed. The wrong assumption: "the saga rolls back automatically."

## 2. Retry Discipline (retry)

**Description:** `:retry` returned as if it were harmless. The DSL default is
`max_retries :infinity`, so a catch-all `:retry` from compensate is an infinite
loop on any permanent failure; retrying deterministic business failures
(declined card, out of stock) re-executes non-idempotent operations and buries
the real domain error; and the default backoff is `:now`, so network retries
without `backoff/4` hammer an already-degraded dependency. The wrong assumption:
"retry is a safe default." Retry is a contract — bounded, transient-only, and
paced.

## 3. Dependency & Data Flow (dep)

**Description:** The DAG ignored in favor of the source file's line order.
Reactor plans from declared dependencies (`argument`, `input`, `result`,
`wait_for`) and runs steps concurrently as soon as their dependencies resolve —
lexical order guarantees nothing. Ordered side effects with no declared edge
race; data smuggled through `context` (or an Agent/ETS) instead of `argument`
creates no edge at all, so readers run before writers; fake unused arguments
hide ordering intent that `wait_for` states outright; and a multi-step reactor
without `return` hands callers an accidental value. The wrong assumption:
"steps run in the order I wrote them."

## 4. Step Contracts (step)

**Description:** Callback return values and DSL entities used against their
documented contracts. `run/3` admits exactly six return shapes — anything else
is treated as a failure and triggers rollback for what was actually a success;
`{:halt, reason}` is a *pause* that skips rollback and returns
`{:halted, reactor}` for resumption, not an error signal; `guard` speaks
`:cont`/`{:halt, result}` while `where` speaks booleans, and skip-conditionals
inlined into `run` bypass both; and side-effecting work written as inline
anonymous functions cannot be mocked, unit-tested, capability-queried via
`can?/2`, or given a `backoff/4`.

## 5. Composition & Iteration (comp)

**Description:** Workflow structure hand-rolled inside step bodies where the
DSL has a planned construct. `Reactor.run` called inside a step hides the child
from the parent's planner and rollback (`compose` propagates undo via
`support_undo?`); `Enum.map` over a collection in one step forfeits per-item
batching, retry, and compensation (`map` provides them); `case` dispatching
different side effects in one step hides branches the planner could skip
(`switch` plans them); `recurse` without `max_iterations` cannot be proven to
terminate; and whole datasets materialized as a `map` source defeat
`batch_size` chunking that streams preserve.

## 6. Concurrency & Process Context (conc)

**Description:** Async defaults assumed instead of read. Steps default to
`async? true` and run in spawned task processes — but `map`'s `allow_async?`
defaults to `false`, so "parallel" map pipelines silently run serially;
sandbox-backed tests that run reactors without `async?: false` fail on
connection ownership; process-local state (Logger metadata, process dictionary,
sandbox allowances) does not follow a step into its task process without
`async? false` or `get_process_context`/`set_process_context` middleware; and
scattering `async? false` across steps to tame load serializes the DAG when the
run-level `max_concurrency` option caps it without losing concurrency.

## 7. Observability & Middleware (obs)

**Description:** Cross-cutting concerns hand-rolled inside steps or wired into
middleware against its contract. `Reactor.Middleware.Telemetry` already emits
start/stop events for run, step, guard, process, compensate, and undo — ad-hoc
`Logger` timing in step bodies duplicates a fraction of that inconsistently;
middleware callbacks have exact return shapes (`init`/`complete`/`halt` return
`{:ok, _}` or `{:error, _}`, `error/2` returns `:ok` or `{:error, _}`,
`event/3` returns `:ok`) and bare returns break the chain; and `event/3` runs inline in the executor, so I/O there stalls every
step event in the reactor.
