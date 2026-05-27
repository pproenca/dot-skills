---
title: Make the Cheapest Way to Improve the Metric the Right One
impact: MEDIUM
impactDescription: prevents cheap degenerate edits from out-scoring real improvement
tags: game, incentive-compatibility, goodhart, agent-optimization
---

## Make the Cheapest Way to Improve the Metric the Right One

An optimizer — especially an automated agent — takes the lowest-cost path to a higher score. If a degenerate edit raises the metric more cheaply than the real improvement, that degenerate edit is what you will get. Design the metric so the easiest available score gain *is* the genuine one. The defenses built in earlier categories — measure on the AST so whitespace and comments don't count, require observational equivalence — are exactly what closes the cheap exploits.

**Incorrect (the cheap path is a fake win):**

```python
# Reward "fewer lines." Cheapest way to win: delete comments, join lines, strip blanks.
score = -count_lines(module)        # an agent maximizes this by minifying, not by improving
```

**Correct (the cheapest win is the genuine one):**

```python
# Measure on the AST (whitespace/comment invariant) AND require ≈. Now the cheapest way to
# drop AST nodes without breaking ≈ is real de-duplication — the behavior you actually want.
def score(before, after, O):
    if not behavior_preserved(before, after, O):
        return float("-inf")            # fake wins are off the table (see game-hard-block-*)
    return size(before) - size(after)   # genuine node removal is the only path up
```

Reference: [Manheim & Garrabrant, "Categorizing Variants of Goodhart's Law" (2018)](https://arxiv.org/abs/1803.04585)
