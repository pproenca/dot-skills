---
title: Express skip conditions as where/guard, not an if around the step body
tags: step, where, guard, skip
---

## Express skip conditions as where/guard, not an if around the step body

Wrapping a step's body in `if condition, do: work(), else: {:ok, nil}` makes
the step "run" either way. To the engine the no-op branch is a success like any
other: undo can later fire for work that never happened (voiding a payment that
was never taken), downstream steps receive a `nil` they must defensively
handle, and the skip is invisible to telemetry (`[:reactor, :step, :guard, *]`
events never fire) and to anyone reading the DSL, where the conditionality
belongs. `where` states the boolean skip on the step itself; `guard` covers the
skip-with-substitute case. The engine then knows the step did not run — and
does not undo it.

**Evidence of violation:** an `if`/`unless`/`case` at the top of a `run`
fn/callback whose skip branch returns a constant no-op result (`{:ok, nil}`,
`{:ok, :skipped}`) around an otherwise side-effecting body, on a step with no
`where`/`guard`. PASS: skip conditions live in `where`/`guard`; `run` bodies
execute unconditionally. N/A: no conditional no-op branches in the target's
steps. Carve-out (citable): the branch is domain logic producing a real,
consumed value (an empty result set is a legitimate answer, not a skip) — cite
the downstream consumer.

```elixir
step :send_reminder, Notifications.SendReminder do
  argument :user, result(:load_user)
  # The condition is part of the plan, not buried in the body —
  # skipped steps are never undone and are visible in telemetry.
  where fn %{user: user}, _ctx -> user.reminders_enabled? end
end
```

Reference: [Reactor DSL — where](https://reactor.hexdocs.pm/dsl-reactor.html)
