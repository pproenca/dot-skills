---
name: staff-level-elixir
description: Use this skill when writing, reviewing, or refactoring Elixir, OTP, Ecto, or Phoenix/LiveView code. It corrects the staff-level judgment calls a capable model gets wrong by default — reaching for a GenServer as the universal tool, rescuing instead of letting processes crash, N+1 Ecto access, non-atomic writes, unbounded/linked Task fan-out, atom exhaustion from user input, eager Enum where Stream fits, and calling Repo from the web layer. Applies whenever the work touches process design, error handling, concurrency, data access, or LiveView, even if the user doesn't name them.
---

# Staff-Level Elixir

Distilled staff-level judgment for Elixir on the BEAM — the design decisions Elixir, OTP, Ecto, and Phoenix force, and how an experienced engineer settles them, written so an agent applies them while writing or reviewing code. Each rule corrects a specific wrong default; there is no rule for things the model already gets right (syntax, basic idioms, the standard library).

## When to Apply

- Writing or reviewing OTP code — deciding whether something needs a process, and which (GenServer, Task, Agent, ETS, supervisor)
- Handling failure — choosing between tagged tuples, exceptions, `with`, and letting a process crash
- Writing Ecto — queries, associations, transactions, changesets, large result sets
- Building Phoenix controllers and LiveViews — context boundaries, socket state, mount lifecycle
- Running concurrent work — parallel fan-out, fire-and-forget tasks, handling untrusted input
- Any request to make Elixir code more idiomatic, more fault-tolerant, or "staff-level"

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Process & OTP Design | `otp-` | Whether a problem needs a process, and which one; supervision |
| 2 | Error Handling & Let-It-Crash | `err-` | Signalling failure; when to raise, rescue, or crash |
| 3 | Idioms & Design Choices | `data-` | Pattern matching, Stream/Enum, iolists, pipes, macros |
| 4 | Concurrency & the Scheduler | `conc-` | Bounded/isolated parallelism; atom-table safety |
| 5 | Ecto & Data Access | `ecto-` | N+1, atomic writes, constraint races, large sets |
| 6 | Phoenix & LiveView | `phx-` | Context boundaries, socket memory, mount lifecycle |

## Quick Reference

### 1. Process & OTP Design

- [`otp-genserver-not-default`](references/otp-genserver-not-default.md) — a GenServer is a serialization point, not the default abstraction
- [`otp-ets-for-shared-reads`](references/otp-ets-for-shared-reads.md) — read-heavy shared state belongs in ETS, not behind a GenServer.get
- [`otp-supervise-over-manual-restart`](references/otp-supervise-over-manual-restart.md) — child specs + DynamicSupervisor/Registry, not hand-rolled restart logic
- [`otp-handle-continue-init`](references/otp-handle-continue-init.md) — defer heavy startup to `handle_continue`; `init/1` blocks the supervisor

### 2. Error Handling & Let-It-Crash

- [`err-tagged-tuples-vs-raise`](references/err-tagged-tuples-vs-raise.md) — `{:ok/:error}` for expected failures, raise only for invariant violations
- [`err-let-it-crash`](references/err-let-it-crash.md) — don't rescue to mask bugs; let the supervisor restart clean state
- [`err-with-happy-path`](references/err-with-happy-path.md) — chain fallible steps with `with`; keep the error term intact

### 3. Idioms & Design Choices

- [`data-pattern-match-over-conditionals`](references/data-pattern-match-over-conditionals.md) — function clauses + guards over if/cond on argument shape
- [`data-stream-vs-enum`](references/data-stream-vs-enum.md) — Stream for large/lazy/early-exit, Enum for small concrete lists
- [`data-iolists-over-concat`](references/data-iolists-over-concat.md) — build large output as iolists; `<>` in a loop is O(n²)
- [`data-pipe-idioms`](references/data-pipe-idioms.md) — pipe a data subject through transformations, not to save a variable
- [`data-functions-over-macros`](references/data-functions-over-macros.md) — solve it with a function before reaching for a macro

### 4. Concurrency & the Scheduler

- [`conc-async-stream-bounded`](references/conc-async-stream-bounded.md) — `Task.async_stream` with `max_concurrency` + explicit `timeout`
- [`conc-task-supervised-nolink`](references/conc-task-supervised-nolink.md) — supervised, unlinked Task for fire-and-forget work
- [`conc-atom-exhaustion`](references/conc-atom-exhaustion.md) — never build atoms from external input; use `to_existing_atom`

### 5. Ecto & Data Access

- [`ecto-preload-n-plus-one`](references/ecto-preload-n-plus-one.md) — preload up front, never inside an Enum loop
- [`ecto-multi-for-transactions`](references/ecto-multi-for-transactions.md) — `Ecto.Multi` for atomic multi-step writes with failure attribution
- [`ecto-db-constraints-over-validation`](references/ecto-db-constraints-over-validation.md) — DB constraint + `unique_constraint`, not a racy validation query
- [`ecto-stream-large-sets`](references/ecto-stream-large-sets.md) — `Repo.stream`/batch large sets; `Repo.all` OOMs at scale
- [`ecto-atomic-counters`](references/ecto-atomic-counters.md) — `update_all` with `inc:` for counters; read-modify-write loses updates

### 6. Phoenix & LiveView

- [`phx-context-boundary`](references/phx-context-boundary.md) — web layer calls contexts, never Repo or schemas directly
- [`phx-liveview-streams`](references/phx-liveview-streams.md) — streams for large/growing collections, not full lists in assigns
- [`phx-mount-twice-connected`](references/phx-mount-twice-connected.md) — gate side effects on `connected?/1`; mount runs twice

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way (with an incorrect/correct contrast only where the wrong way is a real trap).

- [Section definitions](references/_sections.md) — category structure and ordering
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
