---
title: Bound the Files, Tools, and Repositories Codex May Use
impact: HIGH
impactDescription: prevents scope creep into unrelated code that risks side effects on critical-path systems
tags: bound, scope, files, tools, blast-radius
---

## Bound the Files, Tools, and Repositories Codex May Use

A Goal without boundaries lets Codex touch anything it judges relevant — including systems that are not part of the work. State the boundaries explicitly: which directories, which tools, which external services. The narrower the blast radius, the less review surface the user inherits when the Goal completes. Boundaries also help Codex avoid distractions — a perf Goal that's allowed to "investigate everything" tends to drift into refactors that pad the diff without moving the metric. Keep Codex inside the boundary by stating it inside the Goal text; do not rely on it being inferred.

**Incorrect (no boundaries — anything is in scope):**

```text
/goal Reduce p95 checkout latency below 120 ms while keeping the
correctness suite green
```

```text
# Codex may edit shared library code that other services depend on,
# add a caching layer in an unrelated module, or "while I'm here"
# refactor utility code. The diff balloons; review takes hours.
```

**Correct (explicit file/tool boundaries):**

```text
/goal Reduce p95 checkout latency below 120 ms on bench/checkout
while keeping the correctness suite (tests/integration/checkout/**)
green. Use only:
- files under services/checkout/**
- the benchmark fixtures under bench/checkout/fixtures/**
- the tests under tests/integration/checkout/**
Do not edit shared libraries, public API contracts, or anything
outside these paths. If a change outside this boundary is required,
stop and report it as a blocker.
```

```text
# Blast radius confined to one service. Anything outside requires
# explicit user input. Diff is reviewable; Codex cannot silently
# expand scope.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
