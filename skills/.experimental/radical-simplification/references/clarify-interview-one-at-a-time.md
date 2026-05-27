---
title: Interview one question at a time, each with your recommended answer
tags: clarify, polya, socratic, interview
---

## Interview one question at a time, each with your recommended answer

Once a plan exists but before any code is written, the default failure is to commit to assumed answers and produce a fluent solution to a problem the user did not actually have. The opposite default — dumping a wall of seven unrelated questions — is just as bad, because it pushes the cost of thinking back onto the user and signals that the agent has no view. The move is a **dependency-ordered Socratic interview**: walk down the design tree one branch at a time, and for every open decision pose exactly one question paired with your recommended answer and the reasoning behind it. The user then accepts, redirects, or vetoes — and the next question depends on what they chose.

```text
Bad: wall of questions, no recommendations.
  1. What auth provider?
  2. Sync or async?
  3. SQL or document DB?
  4. Where does the queue live?
  5. Retry policy?
  6. Idempotency keys?
  7. ...

  The user has to think from scratch on seven independent axes,
  most of which depend on the answers to the others.

Good: one question, with a recommendation, in dependency order.
  Q1: This flow has one upstream caller and ~50 req/s peak. I'm
      recommending **synchronous, in-process** over a queue —
      a queue adds at-least-once semantics you would then have
      to design around, and the load doesn't justify it.
      Sound right, or is there a reason to decouple I'm missing?

  → User: "Actually we'll add a second caller in Q3 that's bursty."

  Q2: Given the bursty second caller in Q3, I'm now recommending
      a **bounded in-memory buffer with backpressure**, NOT a
      durable queue — bursty != needs-durability, and durability
      reopens the at-least-once design. Does the second caller
      tolerate a 503 under sustained burst, or does it need
      guaranteed acceptance?

  → User: "503 is fine, they retry."

  Q3: Backpressure shape — I'm recommending **token bucket at
      the HTTP layer** over a worker-pool queue, because it
      keeps the failure mode at the edge where the caller can
      observe it. Counter-argument: a pool gives you per-tenant
      isolation. Are tenants a real axis here?
```

Three properties matter. **One question at a time** — sequencing exposes which decisions depend on which, so the user is not being asked to pre-commit to coupled answers. **Always a recommended answer with reasoning** — anchors the conversation in your model of the problem so the user is reviewing a position, not generating one. **Walk the dependency tree, not a flat checklist** — each answer reshapes which questions still matter; questions that became irrelevant should be dropped, not asked.

The mechanical trigger: when a plan is drafted but unresolved decisions remain, do not start implementation. Identify the most upstream unresolved decision (the one other decisions depend on), state your recommendation with one sentence of reasoning, and ask only that question.

Reference: [Pólya — How to Solve It, "The Teacher's Method of Questioning"](https://en.wikipedia.org/wiki/How_to_Solve_It)
