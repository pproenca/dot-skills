---
title: Use wait_for for pure ordering, not an argument the step never reads
tags: dep, wait-for, arguments, intent
---

## Use wait_for for pure ordering, not an argument the step never reads

When a step must follow another without consuming its data, the DSL has a
dedicated word: `wait_for :step_name`, documented as sugar for exactly the
unused-argument trick (`argument :_, result(step)`). Hand-writing the trick
instead — `argument :ignored, result(:send_email)` with `ignored` never
appearing in the `run` body — encodes ordering as what looks like unused data
flow. The next refactor deletes the "dead" argument and silently deletes the
ordering with it, and every reader must reverse-engineer whether the argument
is a mistake or a hidden `wait_for`.

**Evidence of violation:** a named `argument` whose name is never referenced
in the step's `run` fn/callback body (or is bound to `_`), present only to
sequence the step after another. PASS: pure ordering uses `wait_for`; every
declared `argument` is read by the step. N/A: no unused arguments in the
target.

```elixir
step :mark_campaign_sent, Campaigns.MarkSent do
  argument :campaign, input(:campaign)
  # Ordering intent, stated as ordering — survives refactors that
  # would delete an "unused" argument.
  wait_for :send_all_emails
end
```

Reference: [Reactor DSL — wait_for](https://reactor.hexdocs.pm/dsl-reactor.html)
