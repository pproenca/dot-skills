---
title: Rule Title Here
tags: prefix, concept, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. For this skill that usually means naming the older-corpus Ray idiom
the model reproduces (a renamed parameter, a removed class, a pre-V2 pattern)
and what Ray 2.57 does instead — the model generalizes from the reason, not the
instruction. Verify every API claim against the pinned ray wheel before adding
a rule, and prefer examples that run on a local CPU-only cluster.

```python
import ray

@ray.remote
def score_batch(rows: list[dict]) -> list[float]:
    return [score(row) for row in rows]
```

Reference: [Source title](https://docs.ray.io/en/latest/)

<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap. Keep the diff minimal. A strawman foil is worse than
     a single good example. -->
