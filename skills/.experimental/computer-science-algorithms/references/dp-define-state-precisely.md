---
title: Define DP State Precisely Before Writing The Recurrence
impact: HIGH
impactDescription: prevents whole classes of "almost-right" DP bugs and over-large state spaces
tags: dp, state-design, recurrence, correctness
---

## Define DP State Precisely Before Writing The Recurrence

A DP solution is correct only if the state captures everything the recurrence needs to make a decision *without looking at the past*. The most common DP bug is an underspecified state — the answer depends on something not in the state, so the cache returns the wrong value for a "matching" key. The second most common bug is an over-specified state — extra dimensions that don't affect the recurrence inflate the cache and slow the algorithm.

Always write the state definition as one English sentence before coding: "f(i, j) is the length of the longest common subsequence of `a[0..i]` and `b[0..j]`." If you can't say that sentence cleanly, the recurrence isn't ready.

**Incorrect (underspecified state — answer depends on capacity used, but state ignores it):**

```python
def can_partition(arr: list[int]) -> bool:
    # "f(i) = can we partition arr[0..i] into two equal-sum halves?"
    # This is wrong — the answer depends on what sum the current half has so far,
    # which isn't in the state. Memoization will return cached wrong answers.
    from functools import cache
    target = sum(arr) // 2

    @cache
    def f(i: int) -> bool:
        if i == 0:
            return arr[0] == target  # ← only checks one specific running sum
        return f(i - 1) or ...  # whatever you write here, the state is broken
    return f(len(arr) - 1)
```

**Correct (state includes the running sum the decision depends on):**

```python
def can_partition(arr: list[int]) -> bool:
    # State: f(i, s) = can a subset of arr[0..i] sum to exactly s?
    # Decision at i: take arr[i] (→ f(i-1, s - arr[i])) or skip (→ f(i-1, s)).
    total = sum(arr)
    if total % 2:
        return False
    target = total // 2
    from functools import cache

    @cache
    def f(i: int, s: int) -> bool:
        if s == 0:
            return True
        if i < 0 or s < 0:
            return False
        return f(i - 1, s) or f(i - 1, s - arr[i])

    return f(len(arr) - 1, target)
```

**Heuristic for finding the right state:**

Run the brute-force recursion mentally. At each call, ask: "what are *all* the things that determine the answer of this call?" Every one of those goes into the state. Anything that's a function of those (sum, count, set) gets included only if it can't be re-derived.

**Watch for the "set" trap:** if the state seems to require "which subset have I chosen," you typically need bitmask DP (state is an integer 0..2ⁿ-1) — feasible only for n ≤ ~20.

Reference: [USACO Guide — DP introduction](https://usaco.guide/gold/intro-dp)
