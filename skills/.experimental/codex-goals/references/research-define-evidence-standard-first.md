---
title: For Research Goals, Define the Evidence Standard Before Investigation Begins
impact: MEDIUM
impactDescription: prevents the final report from quietly drifting toward a single "done" claim across different epistemic levels
tags: research, evidence-standard, reproduction, epistemic-levels
---

## For Research Goals, Define the Evidence Standard Before Investigation Begins

Research Goals — reproducing a paper, auditing a claim, validating a model — are special because exact proof may not be available. Define the evidence standard before the investigation begins: what counts as exact reproduction, what counts as partial reconstruction, what counts as proxy support, and what should be treated as blocked. This is the single most important step. Without an explicit standard, the final report flattens different levels of support into a single claim and an approximate trained replacement gets reported as exact reproduction. Naming the standard up front means Codex can label its findings honestly during the work and the final report preserves the distinctions the user needs to act on.

**Incorrect (research Goal with no evidence standard):**

```text
/goal Reproduce Buehler et al., "Deep Hedging"
```

```text
# What counts as reproduction? Re-running the original code with the
# original seeds? Training a new model and getting a similar number?
# A figure that looks like the published one? Without a definition,
# Codex picks the most achievable interpretation and calls it done.
```

**Correct (evidence standard defined up front):**

```text
/goal Produce the strongest evidence-backed reproduction of Buehler
et al., "Deep Hedging," using the available paper materials and
local resources.

Evidence standard (label each finding as one of these):
- Confirmed: original code/data was available and ran; numerical
  results match within stated tolerance.
- Approximate reconstruction: rebuilt mechanics, trained new policy
  with new seeds; result is in the same regime as the published one.
- Proxy support: indirect evidence (e.g., a related figure reproduced)
  that supports but does not prove the original claim.
- Blocked: original artifact (seeds, checkpoints, training paths,
  etc.) is not available and no defensible approximation exists.

Attempt every headline result, verify outputs where possible, and
end with a report that separates these four labels per claim.
```

```text
# Codex knows up front how to label each finding. The final report
# preserves the distinctions instead of flattening them. The user
# can trust the labels because they were defined before the work
# started — not retro-fitted to make the result look stronger.
```

Reference: [Using Goals in Codex — Using Goals for complex research](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
