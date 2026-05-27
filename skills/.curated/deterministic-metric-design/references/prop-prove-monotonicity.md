---
title: Prove Monotonicity in the Underlying Property
impact: HIGH
impactDescription: prevents optimization from rewarding the wrong direction
tags: prop, monotonicity, soundness, ordering
---

## Prove Monotonicity in the Underlying Property

A metric must move in the claimed direction when the construct increases. If adding genuinely-redundant code can *lower* a "redundancy" score — because a normalizing denominator grows faster than the numerator — then optimizing the metric can reward making things worse, which is catastrophic when an agent is doing the optimizing. Define the operation that increases the construct and prove the metric is monotone under it.

**Incorrect (ratio that drops when redundancy is added):**

```python
def redundancy(module):
    return cloned_nodes(module) / total_nodes(module)   # add a clone: numerator +k AND denominator +k
# Adding duplicated code can DECREASE this ratio, so "minimize redundancy" can reward duplication.
```

**Correct (absolute count, monotonicity proven):**

```python
# Construct-increasing operation: insert a behavior-preserving duplicate of a subtree.
# Claim: redundancy is non-decreasing under it. Proof: cloned_nodes rises by the subtree
# size and nothing else changes. Optimize the count, not the ratio.
def redundancy(module):
    return cloned_nodes(module)        # provably non-decreasing when a clone is added
```

This mirrors Weyuker's monotonicity property (property 5: |P| ≤ |P;Q|): composing more program onto P must not lower its measure.

Reference: [Weyuker, "Evaluating Software Complexity Measures," *IEEE TSE* 14(9) (1988)](https://doi.org/10.1109/32.6178)
