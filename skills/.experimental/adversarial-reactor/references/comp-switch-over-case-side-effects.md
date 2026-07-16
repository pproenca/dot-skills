---
title: Branch side effects with switch, not a case inside one step
tags: comp, switch, branching, planning
---

## Branch side effects with switch, not a case inside one step

A `case` inside `run` that dispatches to *different side effects per branch*
collapses a fork in the workflow into one opaque step. Each branch loses its
own identity in the plan: its own compensation and undo, its own retry policy,
its own downstream dependencies — and the rollback machinery can only undo
"the step", not "the branch that actually ran". The `switch` entity keeps the
fork in the DSL, where each `matches?` block plans its own steps and only the
taken branch executes. A `case` that merely maps values (same effect, different
data) is fine — the rule is about branches with different effects or different
downstream shapes.

**Evidence of violation:** a `case`/`cond`/multi-clause `if` inside a `run`
fn/callback where at least two branches perform *different externally-visible
side effects* (e.g. one charges, another refunds; one creates, another
deletes), instead of a `switch` on the discriminating value. PASS: effectful
branching is expressed as `switch` with `matches?`/`default` blocks; in-step
conditionals only shape data. N/A: no effectful branching in the target's
steps.

```elixir
switch :settle do
  on result(:classify_adjustment)

  matches? &(&1 == :charge) do
    step :charge, Billing.Charge do
      argument :adjustment, result(:classify_adjustment)
    end
  end

  default do
    step :refund, Billing.Refund do
      argument :adjustment, result(:classify_adjustment)
    end
  end
end
```

Reference: [Reactor DSL — switch entity](https://reactor.hexdocs.pm/dsl-reactor.html)
