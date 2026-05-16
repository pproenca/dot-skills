---
title: Derive Recurrences With The Master Theorem Before Coding Recursion
impact: CRITICAL
impactDescription: prevents shipping accidentally-exponential recursive algorithms
tags: comp, recurrence, master-theorem, divide-and-conquer
---

## Derive Recurrences With The Master Theorem Before Coding Recursion

Recursive algorithms hide their complexity inside the recurrence relation. Two recursions that look similar can have wildly different costs: `T(n) = 2·T(n/2) + O(n)` is O(n log n) (merge sort), `T(n) = 2·T(n-1) + O(1)` is O(2ⁿ) (naive subset enumeration), `T(n) = T(n/2) + O(1)` is O(log n) (binary search). The Master Theorem covers `T(n) = a·T(n/b) + f(n)` — the most common shape — and tells you which of three cases governs the answer.

Always write the recurrence on paper before coding. If you can't derive the recurrence, you don't yet understand the algorithm well enough to ship it.

**Incorrect (recursive Fibonacci — recurrence T(n) = T(n-1) + T(n-2) + O(1), exponential):**

```python
def fib(n: int) -> int:
    # T(n) ≈ φⁿ — for n = 40 this does ~10⁹ calls and takes seconds.
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)
```

**Correct (linear DP — recurrence T(n) = T(n-1) + O(1), O(n)):**

```python
def fib(n: int) -> int:
    # Each subproblem solved once. O(n) time, O(1) space.
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
```

**Master Theorem cheat sheet for T(n) = a·T(n/b) + Θ(n^d):**

| Case | Condition | Result |
|------|-----------|--------|
| 1 | a < bᵈ — work dominated by combine step | Θ(n^d) |
| 2 | a = bᵈ — balanced | Θ(n^d · log n) |
| 3 | a > bᵈ — work dominated by leaves | Θ(n^(log_b a)) |

Worked examples: merge sort `T(n)=2T(n/2)+Θ(n)` → case 2, Θ(n log n). Binary search `T(n)=T(n/2)+Θ(1)` → case 2 with d=0, Θ(log n). Karatsuba `T(n)=3T(n/2)+Θ(n)` → case 3, Θ(n^log₂3) ≈ Θ(n^1.585).

Reference: [CLRS Chapter 4 — Divide-and-Conquer](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
