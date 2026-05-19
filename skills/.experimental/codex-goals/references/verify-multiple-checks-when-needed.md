---
title: Use Multiple Verification Surfaces When a Single Check Is Insufficient
impact: HIGH
impactDescription: prevents single-point-of-failure verification that misses important regressions
tags: verify, multiple, breadth, coverage
---

## Use Multiple Verification Surfaces When a Single Check Is Insufficient

Many real outcomes can't be proven by a single check. Performance work needs both a benchmark and a correctness suite. Migration work needs the data to copy and the application to keep working. Docs work needs the page to build and the commands it cites to still exist. When the outcome has multiple dimensions, name a verification surface for each. The principle is symmetry between the outcome and the evidence — if your outcome implicitly covers three things, your verification must explicitly cover all three. Single-surface verification on multi-dimensional outcomes is how Codex declares a refactor complete because tests pass while the type checker is failing.

**Incorrect (single surface for a multi-dimensional outcome):**

```text
/goal Migrate the auth module from Passport to Lucia, verified by
the auth test suite passing
```

```text
# Surface covered: auth tests.
# Surfaces missed: type checker, end-to-end login flow, session
# cookie format compatibility, downstream consumers of session shape.
# Codex can pass the named surface and leave anything outside it broken.
```

**Correct (one surface per dimension):**

```text
/goal Migrate the auth module from Passport to Lucia, verified by:
(1) the auth test suite (tests/auth/**) passing,
(2) the type checker (tsc --noEmit) returning zero errors,
(3) the end-to-end login flow (e2e/login.spec.ts) passing,
(4) existing session cookies remaining decodable (run scripts/check-session-compat.ts against a snapshot of production cookies)
```

```text
# Each dimension has its own evidence. Completion requires all four.
# Codex cannot trade one dimension for another silently — they must
# all pass simultaneously.
```

**When NOT to use this pattern:**

- Truly single-dimensional outcomes (e.g., "the build script exits 0") — multiple surfaces add ceremony without adding coverage.

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
