# Elixir / OTP / Ecto / Phoenix

**Version 0.1.0**  
dot-skills  
July 2026

---

## Abstract

Staff-level judgment for Elixir on the BEAM: corrects the wrong defaults a capable model makes in process/OTP design, error handling and let-it-crash, everyday idioms, concurrency, Ecto data access, and Phoenix/LiveView.

---

## Table of Contents

1. [Process & OTP Design](references/_sections.md#1-process-&-otp-design)
   - 1.1 [Avoid reaching for a GenServer as the default abstraction](references/otp-genserver-not-default.md)
   - 1.2 [Move heavy init work into handle_continue, not init/1](references/otp-handle-continue-init.md)
   - 1.3 [Supervise processes with child specs instead of restarting by hand](references/otp-supervise-over-manual-restart.md)
   - 1.4 [Use ETS for read-heavy shared state, not a GenServer](references/otp-ets-for-shared-reads.md)
2. [Error Handling & Let-It-Crash](references/_sections.md#2-error-handling-&-let-it-crash)
   - 2.1 [Chain fallible steps with `with`, and keep the error term intact](references/err-with-happy-path.md)
   - 2.2 [Let unexpected failures crash instead of rescuing to mask them](references/err-let-it-crash.md)
   - 2.3 [Return tagged tuples for expected failures, raise for invariant violations](references/err-tagged-tuples-vs-raise.md)
3. [Idioms & Design Choices](references/_sections.md#3-idioms-&-design-choices)
   - 3.1 [Branch with function clauses and guards, not if/cond on argument shape](references/data-pattern-match-over-conditionals.md)
   - 3.2 [Build large output as iolists, not with repeated `<>`](references/data-iolists-over-concat.md)
   - 3.3 [Choose Stream vs Enum by size and composition, not by reflex](references/data-stream-vs-enum.md)
   - 3.4 [Pipe a data subject through transformations, not to save a variable](references/data-pipe-idioms.md)
   - 3.5 [Solve it with a function before reaching for a macro](references/data-functions-over-macros.md)
4. [Concurrency & the Scheduler](references/_sections.md#4-concurrency-&-the-scheduler)
   - 4.1 [Fan out with Task.async_stream, bounded and with an explicit timeout](references/conc-async-stream-bounded.md)
   - 4.2 [Never create atoms from external input](references/conc-atom-exhaustion.md)
   - 4.3 [Use a supervised, unlinked Task for fire-and-forget work](references/conc-task-supervised-nolink.md)
5. [Ecto & Data Access](references/_sections.md#5-ecto-&-data-access)
   - 5.1 [Compose multi-step writes with Ecto.Multi, not nested Repo.transaction](references/ecto-multi-for-transactions.md)
   - 5.2 [Enforce uniqueness with a DB constraint, not a validation query](references/ecto-db-constraints-over-validation.md)
   - 5.3 [Preload associations up front, never inside a loop](references/ecto-preload-n-plus-one.md)
   - 5.4 [Stream or batch large result sets instead of Repo.all](references/ecto-stream-large-sets.md)
   - 5.5 [Update counters with SQL arithmetic, not read-modify-write](references/ecto-atomic-counters.md)
6. [Phoenix & LiveView](references/_sections.md#6-phoenix-&-liveview)
   - 6.1 [Call contexts from the web layer, never Repo or schemas directly](references/phx-context-boundary.md)
   - 6.2 [Gate LiveView side effects on connected?/1 — mount runs twice](references/phx-mount-twice-connected.md)
   - 6.3 [Render large or growing LiveView collections with streams](references/phx-liveview-streams.md)

---

## References

1. [https://hexdocs.pm/elixir/process-anti-patterns.html](https://hexdocs.pm/elixir/process-anti-patterns.html)
2. [https://hexdocs.pm/elixir/design-anti-patterns.html](https://hexdocs.pm/elixir/design-anti-patterns.html)
3. [https://hexdocs.pm/elixir/code-anti-patterns.html](https://hexdocs.pm/elixir/code-anti-patterns.html)
4. [https://hexdocs.pm/elixir/macro-anti-patterns.html](https://hexdocs.pm/elixir/macro-anti-patterns.html)
5. [https://hexdocs.pm/elixir/Task.html](https://hexdocs.pm/elixir/Task.html)
6. [https://hexdocs.pm/elixir/Stream.html](https://hexdocs.pm/elixir/Stream.html)
7. [https://hexdocs.pm/elixir/String.html#to_existing_atom/1](https://hexdocs.pm/elixir/String.html#to_existing_atom/1)
8. [https://www.erlang.org/doc/system/binaryhandling.html](https://www.erlang.org/doc/system/binaryhandling.html)
9. [https://www.erlang.org/doc/apps/stdlib/ets.html](https://www.erlang.org/doc/apps/stdlib/ets.html)
10. [https://hexdocs.pm/credo/Credo.Check.Refactor.PipeChainStart.html](https://hexdocs.pm/credo/Credo.Check.Refactor.PipeChainStart.html)
11. [https://hexdocs.pm/ecto/Ecto.Multi.html](https://hexdocs.pm/ecto/Ecto.Multi.html)
12. [https://hexdocs.pm/ecto/Ecto.Repo.html](https://hexdocs.pm/ecto/Ecto.Repo.html)
13. [https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3](https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3)
14. [https://hexdocs.pm/phoenix/contexts.html](https://hexdocs.pm/phoenix/contexts.html)
15. [https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |