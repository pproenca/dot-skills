---
title: Give the Proxy a Proven Error Direction
impact: CRITICAL
impactDescription: prevents an over-stating proxy from triggering harmful edits
tags: comp, soundness, lower-bound, abstract-interpretation
---

## Give the Proxy a Proven Error Direction

An approximation is only safe to optimize against if you know which way it can be wrong. A proxy with unknown error can mislead an agent into harmful actions — an over-count of "removable code" makes the agent delete code that was needed. Prove the direction: a sound *lower* bound never overstates the good quantity; a conservative *upper* bound never understates a risk. The proof is usually a one-line argument from how the proxy is constructed, and it is what converts a heuristic into something an automated optimizer can trust.

**Incorrect (heuristic estimate, unknown direction):**

```python
# "estimated removable lines" — a regression on features; sometimes over-, sometimes
# under-estimates. An agent that deletes this many lines will sometimes break the build.
def removable_estimate(module):
    return model.predict(features(module))      # no guaranteed direction
```

**Correct (constructed lower bound, direction proven):**

```python
# Proxy = nodes eliminated by behavior-preserving transforms in set T, modulo ≈.
# Theorem: every transform in T preserves ≈, so every counted node is genuinely
# removable → the proxy is a guaranteed lower bound on true reducibility (never over-states).
def removable_lower_bound(module, T, O):
    reduced = apply_all(module, T)              # each step verified ≈-preserving against O
    assert observationally_equivalent(module, reduced, O)
    return size(module) - size(reduced)         # safe to act on: the agent never over-deletes
```

A lower bound that occasionally reports 0 is still safe; an unbounded estimate that occasionally over-reports is not.

Reference: [Cousot & Cousot, "Abstract Interpretation" (POPL 1977)](https://dl.acm.org/doi/10.1145/512950.512973)
