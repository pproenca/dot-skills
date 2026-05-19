---
title: Skip a Goal When the Finish Line Is Vague
impact: CRITICAL
impactDescription: prevents the most common Goal failure mode — open-ended objectives that never close
tags: fit, decision, anti-pattern, vague-targets
---

## Skip a Goal When the Finish Line Is Vague

"Make this better", "refactor this", and "improve the codebase" are not Goals — they are wishes. A Goal must give Codex a way to know when it is done. If you cannot complete the sentence "the work is done when ___ is true", you do not have a Goal yet. The fix is not to set the Goal and hope Codex narrows it; the fix is to define the finish line before activating. Either name the metric ("test suite passes", "p95 < X"), the artifact ("a docs page that explains Y and builds locally"), or the constraint set ("public API behavior unchanged"). If you cannot name any of these, the task is not Goal-shaped — use a prompt to scope the work first.

**Incorrect (vague target, no finish line):**

```text
/goal Refactor this code
```

```text
# Finish line: undefined.
# Codex either spins (each turn finds more to "refactor") or declares
# completion based on aesthetic judgment that may not match the user's.
# The Goal looks active but is structurally identical to "keep working".
```

**Correct (finish line pinned to verifiable state):**

```text
/goal Refactor the OrderProcessor module so that no method exceeds 30
lines and the existing test suite passes unchanged. Public API of
OrderProcessor must remain the same — adding tests is allowed,
changing call sites is not.
```

```text
# End state: every method ≤ 30 lines.
# Verification: existing tests pass; public API unchanged.
# Codex can audit each turn against measurable conditions.
```

**When NOT to use this pattern:**

- Exploratory or open-ended research where the user genuinely wants the model to broaden the search — those are prompts, not Goals.

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
