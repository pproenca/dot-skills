---
title: Require Three Properties Before Setting a Goal — Durable Objective, Evidence Finish Line, Multi-Turn Path
impact: CRITICAL
impactDescription: prevents Goals that either spin forever or finish in one turn anyway
tags: fit, decision, prerequisites, checklist
---

## Require Three Properties Before Setting a Goal — Durable Objective, Evidence Finish Line, Multi-Turn Path

Goals are strongest when the task has all three properties: a durable objective (something that persists meaningfully across turns), an evidence-based finish line (a concrete artifact, test, benchmark, or report that proves completion), and a path that may require several turns of investigation. Missing any one collapses the Goal — without a durable objective it's a prompt; without an evidence finish line Codex can't tell when to stop; without a multi-turn path the persistence is overhead. Check all three before typing `/goal`. If even one is missing, either fix the input (define the evidence) or drop back to a prompt.

**Incorrect (objective without evidence finish line):**

```text
/goal Improve the developer onboarding experience
```

```text
# Durable objective? Yes — "improve" persists across turns.
# Evidence finish line? No — how does Codex prove "improved"?
# Multi-turn path? Possibly, but the missing evidence finish line
# is already enough to disqualify the Goal.
# Result: Codex cannot decide when it's done. Loops or declares
# false completion based on model belief.
```

**Correct (all three present):**

```text
/goal Cut time-to-first-commit for a new engineer below 30 minutes,
verified by running the onboarding script end-to-end on a clean
machine and recording timestamps for each step
```

```text
# Durable objective: cut TTFC below 30 min.
# Evidence finish line: end-to-end script run with recorded timestamps.
# Multi-turn path: identify slow steps → fix → re-run → measure.
# All three present — Goal is well-formed.
```

**When NOT to use this pattern:**

- A vague aspiration with no defined metric ("make onboarding nicer") even when iteration would happen — fix the input first.
- A clearly bounded single edit ("change config X from A to B") — the multi-turn path is missing; a prompt is faster.

Reference: [Using Goals in Codex — When not to use Goals](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
