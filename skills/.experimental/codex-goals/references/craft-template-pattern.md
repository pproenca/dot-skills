---
title: Use the Canonical "verified by … while preserving … Use … Between iterations … If blocked …" Pattern
impact: MEDIUM
impactDescription: prevents partial Goals by surfacing empty clauses before activation
tags: craft, template, pattern, scaffold
---

## Use the Canonical "verified by … while preserving … Use … Between iterations … If blocked …" Pattern

The cookbook gives a canonical scaffold that maps to the six components: `/goal <desired end state> verified by <specific evidence> while preserving <constraints>. Use <allowed inputs, tools, or boundaries>. Between iterations, <how Codex should choose the next best action>. If blocked or no valid paths remain, <what Codex should report and what would unlock progress>.` Start drafts from this pattern. If a clause feels empty, stop and define it before activating — that's exactly the kind of input you want to surface before Codex starts iterating, not after. The scaffold is not the only form a Goal can take, but it's a strong default when you're not sure what to include.

**Incorrect (free-form Goal that omits half the contract):**

```text
/goal I want the checkout flow to be faster and still work, focus on
the new flow that we shipped last week
```

```text
# Direction (faster) but no threshold. Constraint ("still work") but
# no surface to verify it. Boundary hint ("new flow") but not pinned
# to paths. No iteration policy, no blocked stop. Six components, two
# half-defined.
```

**Correct (canonical scaffold filled in):**

```text
/goal Cut p95 latency of POST /checkout/submit below 250 ms,
verified by `npm run bench:checkout-submit` reporting p95 < 250 ms
across 100 runs,
while preserving the integration suite (tests/checkout/**) green and
the request/response schema unchanged.
Use only files under services/checkout-submit/** and the benchmark
fixtures under bench/checkout-submit/**.
Between iterations, record one-line diff, benchmark p95/p99/error rate,
and the hypothesis being tested in bench/checkout-submit/iteration-log.md.
If the benchmark cannot run or no valid paths remain, stop and report
the attempted paths, evidence gathered, the blocker, and the next
input needed to unblock.
```

```text
# Pattern: end state → verification → constraints → boundaries →
# iteration policy → blocked stop. Every clause filled. Codex has a
# complete operating contract from turn one.
```

Reference: [Using Goals in Codex — How to write a Goal](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
