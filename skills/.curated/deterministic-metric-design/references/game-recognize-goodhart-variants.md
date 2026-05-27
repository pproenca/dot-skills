---
title: Recognize the Goodhart Variants Before You Optimize
impact: MEDIUM
impactDescription: prevents extremal Goodhart from silently breaking the proxy
tags: game, goodhart, extremal, causal
---

## Recognize the Goodhart Variants Before You Optimize

"When a measure becomes a target, it ceases to be a good measure." Manheim and Garrabrant separate this into distinct failure modes: *regressional* (the proxy carries noise, so the top of the proxy is not the top of the goal), *extremal* (the proxy–goal correlation holds in the normal range but breaks in the tail you optimize into), and *causal* (intervening on the proxy does not move the goal because the correlation was never causal). Naming the variant you face tells you what to watch for and how hard you can safely push.

**Incorrect (optimize hard, assume the correlation holds at the extreme):**

```python
# Coverage correlated with quality historically, so drive coverage to 100%.
while coverage(suite) < 1.0:
    add_tests_until_covered()        # extremal Goodhart: tests that assert nothing; coverage ≠ quality
```

**Correct (bound the push; re-validate at the new operating point):**

```python
# Optimize only within the validated range, then re-check the proxy↔goal link before going further.
target = min(coverage(suite) + 0.05, VALIDATED_CEILING)   # don't optimize into the untested tail
improve_until(coverage, target)
assert mutation_score_improved(suite), "coverage rose but fault detection did not — stop pushing"
```

Reference: [Manheim & Garrabrant, "Categorizing Variants of Goodhart's Law" (2018)](https://arxiv.org/abs/1803.04585)
