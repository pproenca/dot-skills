---
title: Prove A Greedy Choice With An Exchange Argument Before Coding It
impact: MEDIUM
impactDescription: prevents shipping greedy algorithms that are silently incorrect
tags: greedy, exchange-argument, correctness, proof
---

## Prove A Greedy Choice With An Exchange Argument Before Coding It

Greedy algorithms are fast and short — when they work. The trouble: many problems look greedy-shaped but require DP for correctness (0/1 knapsack, longest path), and silently-wrong greedy solutions pass most test cases. The defense: before writing a greedy algorithm, prove its correctness via an **exchange argument** — show that if any optimal solution disagrees with the greedy choice at step k, you can swap in the greedy choice without losing optimality. If you can't construct that argument, don't ship the greedy; use DP.

Three problems greedy *does* solve optimally: activity selection (sort by finish time), Huffman coding (always merge two smallest), and minimum-spanning-tree (cut property). Each has a clean exchange-argument proof. Coin change with arbitrary denominations is a famous example where greedy *fails*.

**Incorrect (greedy coin change with non-canonical denominations — wrong answer):**

```python
def greedy_coin_change(coins: list[int], amount: int) -> int:
    # For coins = [1, 3, 4] and amount = 6, greedy picks 4 + 1 + 1 = 3 coins.
    # Optimal is 3 + 3 = 2 coins. Greedy is silently wrong.
    coins = sorted(coins, reverse=True)
    used = 0
    for c in coins:
        used += amount // c
        amount %= c
    return used if amount == 0 else -1
```

**Correct (DP coin change — always optimal):**

```python
def coin_change(coins: list[int], amount: int) -> int:
    # dp[w] = min coins to make w. O(amount · |coins|).
    INF = float("inf")
    dp = [0] + [INF] * amount
    for w in range(1, amount + 1):
        for c in coins:
            if c <= w and dp[w - c] + 1 < dp[w]:
                dp[w] = dp[w - c] + 1
    return -1 if dp[amount] == INF else dp[amount]
```

**A *correct* greedy with an exchange argument — activity selection:**

```python
def max_non_overlapping(intervals: list[tuple[int, int]]) -> int:
    # Sort by finish time; pick the earliest-finishing compatible interval each step.
    # Exchange argument: any optimal solution can be modified to match this greedy choice
    # at step 1 without losing optimality — swap its first interval for ours, the rest
    # still fit. Induction completes the proof.
    intervals = sorted(intervals, key=lambda x: x[1])
    count, last_end = 0, -float("inf")
    for s, e in intervals:
        if s >= last_end:
            count += 1
            last_end = e
    return count
```

**When greedy is tempting but wrong:** 0/1 knapsack ("pick highest value-per-weight"), graph colouring ("pick the highest-degree node"), longest path in general graphs. All NP-hard or counter-example-prone.

Reference: [CLRS Chapter 15 — Greedy Algorithms](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
