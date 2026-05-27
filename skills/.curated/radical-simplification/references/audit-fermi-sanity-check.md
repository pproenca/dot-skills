---
title: Bound the answer with a Fermi estimate before producing it
tags: audit, fermi, sanity-check
---

## Bound the answer with a Fermi estimate before producing it

Fermi's habit: before computing or measuring, estimate the answer's order of magnitude from first principles. If the eventual measurement disagrees with the estimate by more than 10×, the measurement (or the estimate) is wrong, and the disagreement is where the real problem lives. The default agent failure is to produce a number with no prior — so it has no way to notice when the number is implausible.

```text
Question: "How many DB queries does this checkout endpoint make?"

Fermi estimate (before reading the trace, ~30 seconds of thinking):
  1× session lookup
  1× user row
  1× cart fetch
  N× cart items (or 1 if batched)  → N or 1
  1× payment record write
  1× order row write
  1× audit log write
                                   ────
                                   ~7 to (7 + items)

Trace shows: 47 queries on a 4-item cart.

The Fermi estimate said ~11. The measurement is 4× too high — and
that gap is the bug. Likely culprits: an N+1 on items, plus an
unbatched fetch of related entities. Confirmed in 2 minutes.

Without the estimate, "47 queries" looks like a number — it is only
"too many" if you had a sense of what "enough" was.
```

The estimate does not have to be precise; an order of magnitude is enough. Apply it to: query counts, response sizes, memory usage, request rates, cache hit rates, anything where the agent is about to produce a number. If the actual differs by 10×, do not move on — the gap is the signal.

Reference: [University of Maryland — Fermi Questions in physics teaching](https://www.physics.umd.edu/perg/fermi/fermi.htm)
