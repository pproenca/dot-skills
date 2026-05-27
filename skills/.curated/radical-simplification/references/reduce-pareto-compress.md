---
title: Cut to the 20% that produces 80% of the result
tags: reduce, pareto, knuth, compression
---

## Cut to the 20% that produces 80% of the result

The default failure mode is enumeration: the agent lists every case, handles every branch, supports every option. Most of the cost goes to inputs that are rare or unimportant. Find the 20% — by counting calls, measuring traffic, or asking the user which cases actually matter — and design for that. The rest can be a fallback path, a `not_supported` error, or deferred entirely.

```text
Endpoint cache design across 47 routes.

Measured: 3 routes account for 91% of read traffic:
  GET /users/me          (54%)
  GET /feed              (24%)
  GET /notifications     (13%)

Pareto cut:
  Cache those three behind a per-user invalidation key.
  Leave the other 44 routes uncached — they cost more to invalidate
  correctly than they cost to serve hot.

Result: 91% of traffic absorbed by ~150 lines of cache logic.
Enumerating all 47 would have been ~3000 lines and a stale-data
incident, for 9% more coverage.
```

This is not laziness — it is honest pricing. Every uncommon case the agent supports trades real complexity (which costs forever) for marginal coverage (which often costs nothing because the case never occurs). Knuth's "premature optimization" applies to the choice of *what to make complicated*, not just to micro-tuning.

Reference: [Knuth — Structured Programming with go to Statements (ACM Computing Surveys, 1974)](https://dl.acm.org/doi/10.1145/356635.356640)
