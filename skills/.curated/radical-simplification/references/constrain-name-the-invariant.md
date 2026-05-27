---
title: Name the invariant — it is usually the answer
tags: constrain, invariants, knuth
---

## Name the invariant — it is usually the answer

By default the agent reasons about how state *changes* and loses track of what does not. The invariant — the property that must hold at every step — is usually the simplest statement of what the system actually does. Once named, the implementation is a question of "preserve this invariant", and most of the "edge cases" collapse into "moves that would have broken the invariant".

```text
Concurrent reference counter — many threads acquire and release,
the resource is dropped when no one holds it.

Without naming the invariant: argue about CAS loops, fences, ABA,
memory ordering, "what if a release happens during an acquire"…

Invariant: at all times,
  count = (number of acquires not yet matched by a release)
  AND
  count = 0  ⇔  no live reference exists.

Now the design constrains itself:
  - Acquire = atomic increment; allowed only if count > 0 (otherwise the
    invariant says no reference exists, so there is nothing to acquire).
  - Release = atomic decrement; if it brings count to 0, drop the resource.
  - The ABA case is impossible because the invariant rules out
    "count went 1 → 0 → 1" without a re-acquire from outside the resource.

The CAS subtleties did not go away — they fell out of obeying one line.
```

The invariant is also the documentation: a future reader who knows the invariant can derive the code; a reader who knows the code may never deduce the invariant. Write it in the file.

Reference: [Hoare — An Axiomatic Basis for Computer Programming (CACM, 1969)](https://dl.acm.org/doi/10.1145/363235.363259)
