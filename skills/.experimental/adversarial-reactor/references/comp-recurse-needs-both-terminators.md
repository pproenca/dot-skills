---
title: Give recurse both an exit_condition and max_iterations
tags: comp, recurse, termination, iteration
---

## Give recurse both an exit_condition and max_iterations

`recurse` re-runs a reactor with its own output as the next input until told
to stop. The recursion guide's own rule is to always provide both termination
conditions: an `exit_condition` that expresses "done", and `max_iterations` as
the backstop for the day the condition cannot be met — a fixpoint that
oscillates, an upstream API that never drains, a bug in the condition itself.
The wrong default is trusting the exit condition alone: it encodes the happy
path, and without the bound, the unhappy path is a reactor that never
terminates. The guide also scopes the entity: walking a collection is `map`'s
job, not `recurse`'s.

**Evidence of violation:** a `recurse` block missing `max_iterations` (or
missing any `exit_condition` while relying on `max_iterations` alone as the
loop's semantics); or a `recurse` whose composed reactor consumes head/tail of
a list per iteration — a collection walk that `map` plans with batching and
per-item semantics. PASS: every `recurse` declares both `exit_condition` and
`max_iterations`, and recursion is used for genuinely self-referential work
(pagination cursors, hierarchical expansion, convergence). N/A: no `recurse`
in the target.

```elixir
recurse :drain_queue, Imports.DrainPage do
  argument :cursor, input(:initial_cursor)
  exit_condition fn %{cursor: cursor} -> is_nil(cursor) end
  # Backstop for the day the API never returns a nil cursor.
  max_iterations 1_000
end
```

Reference: [Reactor — Recursive Execution guide](https://reactor.hexdocs.pm/05-recursive-execution.html)
