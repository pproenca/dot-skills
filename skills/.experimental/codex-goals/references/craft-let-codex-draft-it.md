---
title: Ask Codex to Draft the Goal from a Plain-Language Description, Then Tighten
impact: MEDIUM
impactDescription: reduces authoring cost for strong Goals by splitting drafting from tightening
tags: craft, draft, workflow, codex-assisted
---

## Ask Codex to Draft the Goal from a Plain-Language Description, Then Tighten

When the task is clear but the Goal text is not, ask Codex to write the Goal for you. Step one: describe what you want in plain language and ask Codex to turn it into a draft `/goal`. Step two: review the draft and tighten the success condition, verification surface, constraints, and blocked stop condition before activating. Codex is good at producing a draft that includes the six components in the canonical pattern — what it can't do is read your mind about which surfaces matter most, which constraints are non-negotiable, or what the real unblocking inputs are. The draft saves time; the tightening saves correctness. Don't activate Codex's first draft as-is — that's a category of Goal that looks complete but isn't.

**Incorrect (skip the draft, write a thin Goal by hand under time pressure):**

```text
User: /goal Fix the flaky checkout test
```

```text
# No verification surface specified, no constraint on side effects,
# no blocked stop. Thin Goals from impatient hand-writing are how
# Goals fail.
```

**Correct (two-step: ask Codex to draft, then tighten):**

```text
User: "Help me turn this into a strong /goal: I want Codex to keep
working on the flaky checkout test until we either fix it with
evidence or can clearly explain what's blocking progress."

Codex (draft): "/goal Reproduce and fix the flakiness in
tests/checkout/test_payment_flow, verified by 100 consecutive passing
runs of that test on a clean checkout, while preserving all other
tests in tests/checkout/** passing and the public CheckoutController
API unchanged. Use only files under services/checkout/** and
tests/checkout/**. Between iterations, record the failure mode
observed, the hypothesized cause, the fix attempted, and the result.
If the flake cannot be reproduced or the cause is outside the
boundary, report the attempted paths, the evidence gathered, the
blocker, and the next input needed."

User (after review): "Tighten — change '100 consecutive runs' to
'500 runs with no more than 1 failure', and add that the fix must
not extend total suite runtime by more than 10%."

User: /goal [tightened version]
```

```text
# Codex's draft gives a complete-looking Goal. The user's review
# catches what Codex couldn't infer (real flakiness threshold,
# performance constraint) before activation.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
