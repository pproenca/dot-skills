---
title: Choose a Prompt for Single-Turn Work, a Goal for Outcome-Driven Continuation
impact: CRITICAL
impactDescription: prevents miscategorizing work and choosing the wrong operating model
tags: fit, decision, prompts, mental-model
---

## Choose a Prompt for Single-Turn Work, a Goal for Outcome-Driven Continuation

The two operating models are not interchangeable. A prompt is "ask → work → result → wait" — Codex executes the immediate instruction, reports back, and stops. A Goal is "work → check → continue or complete" — Codex evaluates evidence after each turn and continues if the objective is still unmet and the Goal is within budget. The cost of confusing the two is real: a prompt forced into a Goal-shaped task makes the user retype "keep going" every turn; a Goal forced onto a prompt-shaped task attaches state Codex must maintain for work that closes in one turn. Diagnose the shape before choosing.

**Incorrect (prompt repeated where a Goal belongs):**

```text
User: Profile the request handler and find the slowest path
Codex: [profiles, reports top 3 hot functions]
User: Now fix the top one
Codex: [fixes function A]
User: Now rerun the benchmark
Codex: [reruns, latency still above target]
User: Try fixing the next one
Codex: [fixes function B]
User: Rerun and check
```

```text
# Every "next" turn the user restates the target. The objective lives
# in the user's head, not the thread. Codex cannot evaluate completion
# between turns because there is no persisted finish line.
```

**Correct (Goal for the iterative outcome, prompts for one-shot probes):**

```text
/goal Reduce p95 request latency below 80 ms on the staging benchmark
while keeping the integration tests green

# Mid-Goal one-shot probe — does not need its own Goal:
What does the flamegraph from the last benchmark run show as the top
allocator?
```

```text
# The Goal owns the outcome. One-shot prompts during the Goal are
# fine — they answer specific questions without redefining the target.
# Codex returns to the Goal after answering.
```

Reference: [Using Goals in Codex — Goals vs prompts](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
