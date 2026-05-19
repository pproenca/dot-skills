---
title: Use a Goal When the Finish Line Is Clear but the Path Is Uncertain
impact: CRITICAL
impactDescription: prevents misuse of persistence machinery on single-turn tasks
tags: fit, decision, scope, when-to-use
---

## Use a Goal When the Finish Line Is Clear but the Path Is Uncertain

A Goal is a persistent objective with a completion contract. It is the right tool only when the work has both a verifiable end state and a path that may require several turns of investigation — performance tuning, flaky-test investigation, dependency migration, multi-step refactor, benchmark-driven tuning, or research producing a final artifact. For a one-line edit, a code explanation, or a question with one answer, a normal prompt closes faster and avoids attaching state Codex must maintain. Misapplying Goals doesn't just waste machinery — it trains the user to ignore the lifecycle controls that make Goals safe.

**Incorrect (Goal for a one-shot edit):**

```text
/goal Rename the variable userId to accountId in src/auth/session.ts
```

```text
# This is a single deterministic edit. There is no iteration, no
# evidence to gather, no decision the next turn would make differently.
# A plain prompt completes it in one turn without persistent state.
```

**Correct (Goal for an iterative outcome):**

```text
/goal Reduce p95 checkout latency below 120 ms on the checkout benchmark
while keeping the correctness suite green
```

```text
# Iterative: inspect hot path → change → rerun benchmark → check tests
# → continue if not below threshold. Persistent objective survives
# intermediate results without restating the target each turn.
```

**When NOT to use this pattern:**

- One-line edits, simple explanations, short code reviews, or questions where you want one answer and then a stop.
- Tasks where the finish line is vague ("make this better", "refactor this") with no defined end state, tests, or constraints.
- Tasks where you would not be willing to let Codex spend multiple turns iterating.

Reference: [Using Goals in Codex — Quickstart](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
