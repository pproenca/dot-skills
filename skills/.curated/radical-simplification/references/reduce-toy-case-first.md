---
title: Solve the smallest non-trivial case fully before generalizing
tags: reduce, polya, toy-model
---

## Solve the smallest non-trivial case fully before generalizing

By default the agent attacks the general N case directly. The general case carries every parameter at once, so failures could come from any of them and the agent flounders. Solving n=1 (or the smallest case where the problem is still genuine — n=2 if n=1 is degenerate) fully, *including the corner cases*, surfaces the structure; the general algorithm then usually falls out as a fold over the small case.

```text
Problem: reconcile balances across N accounts moving through M intermediaries.

Don't: jump to "build a graph, walk edges, sum at sinks".

Toy case: N=2 accounts (A, B), M=1 intermediary (X).
  A → X: -100
  X → B: +100
  Reconciled when sum(A) + sum(B) + sum(X) = 0 AND sum(X) = 0 in steady state.

What this exposes:
  - In-flight transfers are the source of imbalance, not the algorithm.
  - The interesting state is "X's pending balance", not "edges in a graph".
  - Generalizing to N>2 is a sum; generalizing to M>1 is a sum-of-sums.

General algorithm now: "every node's net = 0, every intermediary's
in-flight = 0". One line, found via the toy case.
```

If the toy case feels trivial or boring, you have picked it correctly. The point is not to solve a small thing — it is to make the structure of the big thing visible.

Reference: [Pólya — How to Solve It (Princeton UP, 1945)](https://en.wikipedia.org/wiki/How_to_Solve_It)
