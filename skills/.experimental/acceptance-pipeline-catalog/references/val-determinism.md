---
title: Seed All Randomness from Mutation Path and Value
impact: HIGH
impactDescription: non-deterministic mutations make results non-reproducible, breaking every cross-run diff and CI gate that depends on stable mutation IDs
tags: val, value, determinism, pseudo-random, seed, reproducibility
---

## Seed All Randomness from Mutation Path and Value

All random choices in value mutation must be pseudo-random and deterministic. This means the same IR input always produces the same set of mutations, making results reproducible and diffable across runs.

### Spec Requirements

All random choices must be **pseudo-random and deterministic** for a fixed **mutation path** and **original value**.

This applies to:
- Integer and float deltas (the magnitude and sign of the shift).
- Date/time and duration shifts (the direction and amount).
- String dithering (which edit operation, which character position, which replacement character).
- Comma-list item selection (which item to mutate).

### What "Fixed Mutation Path + Original Value" Means

The mutation path (e.g., `$.scenarios[0].examples[0].count`) and the original value (e.g., `"20"`) together form the seed for random choices. This means:

- Running the mutator twice on the same IR produces identical mutations.
- Different cells with the same value may produce different mutations (because their paths differ).
- The same cell in different IRs produces the same mutation (if path and value match).

### Implementation Approach

A common approach is to hash the mutation path and original value to produce a seed for a pseudo-random number generator. The PRNG then drives all random choices for that mutation. Any deterministic hash function and any PRNG work, as long as the implementation is consistent.

### Examples

**Incorrect (uses system random, producing different mutations each run):**

```python
import random

def mutate_integer(value, path):
    delta = random.randint(1, 10)  # non-deterministic
    return str(int(value) + delta)
```

**Correct (seeds PRNG from mutation path + original value for reproducibility):**

```python
import hashlib, random

def mutate_integer(value, path):
    seed = hashlib.sha256(f"{path}:{value}".encode()).digest()
    rng = random.Random(int.from_bytes(seed[:8], "big"))
    delta = rng.choice([-7, -5, -3, 3, 5, 7])
    return str(int(value) + delta)
```

### Why This Matters

Reproducibility is fundamental to mutation testing as a quality tool. When a developer sees "m3 survived" in a report, they need to reproduce that exact mutation to investigate. If re-running the mutator produces different mutations, the IDs shift, and the investigation targets the wrong cell.

Determinism also enables CI integration: the same codebase with the same feature file produces the same mutation results, so "all mutations killed" is a stable, verifiable property.
