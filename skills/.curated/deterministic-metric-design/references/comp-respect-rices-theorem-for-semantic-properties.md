---
title: Respect Rice's Theorem When Measuring Semantic Properties
impact: CRITICAL
impactDescription: prevents promising an exact count of an undecidable property
tags: comp, rices-theorem, undecidability, static-analysis
---

## Respect Rice's Theorem When Measuring Semantic Properties

Rice's theorem says every non-trivial semantic property of programs is undecidable — "this statement is unreachable on all inputs," "these two functions are equivalent," "this variable is always null here" cannot be decided exactly in general. A metric that promises an *exact* count of a semantic property is promising the undecidable, and its implementation will be silently wrong on the hard cases. The fix: compute a sound static approximation and state its direction — count only what the analysis can *prove*, accepting that it under- or over-counts but never errs in the dangerous direction.

**Incorrect (claims an exact semantic count):**

```python
# "dead statements" — claims to count exactly the statements that never execute
def dead_statements(module):
    return [s for s in module.statements if never_executes(s)]   # UNDECIDABLE in general
# never_executes() cannot be a correct total function — it encodes the halting problem.
```

**Correct (sound under-approximation, direction stated):**

```python
# Count only statements a sound reachability analysis PROVES unreachable.
# Direction: under-count — may miss some dead code, never flags live code as dead.
def provably_dead_statements(module, cfg):
    reachable = sound_reachability(cfg)          # conservative: errs toward "reachable"
    return [s for s in module.statements if s not in reachable]
```

The conservative direction is what makes the number safe for an agent to act on: it will never delete a statement that might run.

Reference: [Rice (1953), "Classes of Recursively Enumerable Sets and Their Decision Problems," *Trans. AMS* 74(2)](https://www.ams.org/journals/tran/1953-074-02/S0002-9947-1953-0053041-6/)
