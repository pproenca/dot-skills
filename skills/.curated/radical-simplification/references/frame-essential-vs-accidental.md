---
title: Separate essential complexity from accidental complexity
tags: frame, brooks, complexity
---

## Separate essential complexity from accidental complexity

Brooks's distinction: **essential** complexity is inherent to the problem; **accidental** complexity is whatever the current tools, libraries, and codebase shape have layered on top. By default the agent treats the codebase's current shape as essential and adds more layers to fit it. Naming each piece as one or the other surfaces what can be moved out, replaced, or skipped versus what must be solved on its merits. Brooks's own thesis was that in mature systems essential complexity already dominates and no 10× lever hides in accident; in fresh and AI-generated code, accidents accrete faster, so the distinction earns its keep most heavily there.

```text
Function: processOrderWithRetryAndIdempotencyAndAnalytics(order, retryCount, idempotencyKey, analyticsCtx)

Essential to "process an order":
  - Validate, reserve inventory, charge payment, write order row.

Accidental (could be moved out without changing what processing means):
  - Retry → the queue's job; the function should be idempotent and fail fast.
  - Idempotency key → a wrapper / middleware concern.
  - Analytics context → a side effect emitted from a single layer above.

After separation, the essential function is ~20 lines and the accidents
sit on the call edge where they can be reasoned about independently.
```

The test: if a piece of complexity would still exist if you rewrote the system from scratch in a different language and stack, it is essential. If it would not, it is accidental — and a candidate to push out, not solve harder.

Reference: [Brooks — No Silver Bullet (IEEE Computer, 1987)](https://en.wikipedia.org/wiki/No_Silver_Bullet)
