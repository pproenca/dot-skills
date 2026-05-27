---
title: Pin Iteration Order and Tie-Breaking
impact: HIGH
impactDescription: prevents run-to-run variance from unordered iteration and hash seeds
tags: det, ordering, tie-breaking, hash-seed
---

## Pin Iteration Order and Tie-Breaking

Iterating over sets, dicts, or filesystem listings in unspecified order, or breaking ties arbitrarily, makes a metric return different values across runs, machines, and interpreter versions — Python randomizes string hashing per process by default, and `os.listdir` order is filesystem-dependent. A ranking or "top offender" metric built on unordered traversal is silently non-deterministic, so the agent optimizing it chases ghosts. Sort by a *total* key and seed any randomness.

**Incorrect (order depends on hashing / filesystem):**

```python
worst = max(find_clones(repo), key=lambda c: c.size)   # ties broken by set iteration order
files = os.listdir(src)                                  # order varies by filesystem
```

**Correct (total ordering and fixed traversal):**

```python
clones = sorted(find_clones(repo), key=lambda c: (-c.size, c.path, c.start_line))  # total key
worst = clones[0]                                        # deterministic tie-break
files = sorted(os.listdir(src))                          # fixed order
# Run any dict/set-dependent step under a fixed hash seed: PYTHONHASHSEED=0
```

Reference: [Python docs — `PYTHONHASHSEED` (hash randomization)](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONHASHSEED)
