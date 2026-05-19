---
title: For Generated Artifacts, Name the Artifact and Its Validity Conditions
impact: HIGH
impactDescription: enables artifact-level audit instead of completion based on plausibility
tags: outcome, artifact, documentation, validity
---

## For Generated Artifacts, Name the Artifact and Its Validity Conditions

When the outcome is a generated artifact — docs, a config file, a migration, a report — the Goal must name both the artifact and the conditions that make it valid. "Write docs for this feature" gives Codex nothing to audit. A stronger formulation names what the page must contain, where it lives, and what "builds and works" means. Codex can then inspect the produced artifact against those conditions instead of declaring completion on plausibility. The validity conditions are the audit surface for artifact Goals — they are not optional decoration.

**Incorrect (no artifact specification):**

```text
/goal Write docs for the new Goals feature
```

```text
# What page? Where? In what format? What must it cover?
# Codex produces something plausible. Whether it's complete or correct
# is a matter of opinion, not audit.
```

**Correct (artifact + validity conditions):**

```text
/goal Produce a docs page for Goals at docs/codex/goals.md that
explains the lifecycle (set, pause, resume, clear, complete), the
command surface, and two end-to-end examples (one performance, one
research). Verify that the page builds locally with the existing
docs build script and that every referenced command matches the
current CLI behavior in `codex --help`.
```

```text
# Artifact: docs/codex/goals.md
# Required sections: lifecycle, command surface, two examples
# Validity checks: builds locally; commands match `codex --help`
# Codex can inspect the produced page against each condition.
```

Reference: [Using Goals in Codex — Turning a weak Goal into a strong one](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
