---
title: Define Six Components in Every Strong Goal — Outcome, Verification, Constraints, Boundaries, Iteration Policy, Blocked Stop
impact: MEDIUM
impactDescription: prevents missing components that predict Goal failure modes (Pyrrhic completion, scope creep, fake completion)
tags: craft, components, checklist, contract
---

## Define Six Components in Every Strong Goal — Outcome, Verification, Constraints, Boundaries, Iteration Policy, Blocked Stop

The strongest Goals typically define six things explicitly: (1) outcome — what should be true when the work is done; (2) verification surface — the test, benchmark, report, artifact, command output, or source material that proves it; (3) constraints — what must not regress while Codex works; (4) boundaries — which files, tools, data, repositories, or resources Codex may use; (5) iteration policy — how Codex should decide what to try next after each attempt; (6) blocked stop condition — when Codex should stop and report that no defensible path remains. Use the checklist when writing or reviewing a Goal. Missing components don't break the Goal immediately, but they predict where it will go wrong: missing constraints predict Pyrrhic completions; missing boundaries predict scope creep; missing blocked stops predict spinning or fake completion.

**Incorrect (thin Goal — only outcome and one constraint):**

```text
/goal Reduce p95 checkout latency below 120 ms without regressing
correctness tests
```

```text
# Missing: verification surface (which benchmark? which suite?),
# boundaries (where can Codex edit?), iteration policy (how to choose
# the next experiment?), blocked stop (what to do when stuck?).
# Workable but will produce avoidable surprises.
```

**Correct (all six components stated):**

```text
/goal Reduce p95 checkout latency below 120 ms,
verified by `npm run bench:checkout` reporting p95 < 120 ms across
50 runs,
while keeping the correctness suite (tests/integration/checkout/**)
green and the public CheckoutController API unchanged.
Use only files under services/checkout/**, bench/checkout/**, and
tests/integration/checkout/**.
Between iterations, record what changed, what the benchmark showed,
and the next best experiment to try in bench/checkout/iteration-log.md.
If the benchmark cannot run or no valid paths remain inside the
boundary, stop with attempted paths, evidence gathered, the blocker,
and the next input needed.
```

```text
# (1) Outcome: p95 < 120 ms.
# (2) Verification: bench:checkout, 50 runs.
# (3) Constraints: integration suite green, public API unchanged.
# (4) Boundaries: three named paths only.
# (5) Iteration policy: record-changed/showed/next, log location.
# (6) Blocked stop: defined trigger and report contents.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
