---
title: Prune Recursive Search With Bounds and Constraints
impact: HIGH
impactDescription: Worst-case exponential, practical 10-1000× speedup
tags: rec, branch-and-bound, backtracking, pruning, search
---

## Prune Recursive Search With Bounds and Constraints

Combinatorial search problems — subset sum, knapsack, traveling salesman, constraint solving, AI search — are exponential in worst case, but most real instances admit massive pruning. A best-so-far bound that compares against the current partial solution lets you abandon branches that cannot possibly improve it; constraint propagation eliminates entire subtrees before exploring them. The general pattern: track an upper/lower bound, cheaply estimate the best possible completion at each node, prune branches that can't beat the current best. The Big-O stays exponential but constant factors collapse — what was 2⁴⁰ becomes a few million nodes.

**Incorrect (brute-force enumeration — O(2ⁿ) every time):**

```python
def subset_sum(nums, target):
    """Does any subset sum to target?"""
    def helper(i, current):
        if current == target:
            return True
        if i == len(nums):
            return False
        # Try both: include nums[i], or skip it
        return helper(i + 1, current + nums[i]) or helper(i + 1, current)

    return helper(0, 0)
# n=30 → 2^30 ≈ 1 billion calls in worst case
```

**Correct (prune when partial sum overshoots or sort by largest first):**

```python
def subset_sum(nums, target):
    nums = sorted(nums, reverse=True)        # largest first → fast overflow
    # Precompute suffix sums once — sum(nums[i:]) is O(1) via lookup, not O(n)
    suffix = [0] * (len(nums) + 1)
    for i in range(len(nums) - 1, -1, -1):
        suffix[i] = suffix[i + 1] + nums[i]

    def helper(i, current):
        if current == target:
            return True
        if current > target:                  # PRUNE: overshot
            return False
        if i == len(nums):
            return False
        # Optimistic bound: even taking all remaining, can we reach target?
        if current + suffix[i] < target:      # PRUNE: undershoot impossible
            return False
        return helper(i + 1, current + nums[i]) or helper(i + 1, current)

    return helper(0, 0)
# Same worst case but typically thousands of nodes, not billions —
# and each node is O(1), not O(n) as a naive sum(nums[i:]) would make it
```

**Alternative (constraint propagation — Sudoku / SAT solvers):**

```python
# When picking a value forces or excludes values elsewhere, propagate immediately
# instead of recursing into branches that constraint violation will reject
```

**When NOT to use this pattern:**
- When the search space is small enough that brute force is faster than designing bounds — pruning has overhead.
- When the problem has provable polynomial structure (it's not actually combinatorial) — use DP or a polynomial algorithm instead.

Reference: [Branch and bound (NIST DADS)](https://xlinux.nist.gov/dads/HTML/branchNbound.html)
