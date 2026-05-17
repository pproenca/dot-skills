---
title: Defer or Short-Circuit Work You Might Not Need
impact: MEDIUM
impactDescription: Eliminates work entirely — speedup depends on hit rate but often 2-10×
tags: compute, lazy-evaluation, short-circuit, deferred, optimization
---

## Defer or Short-Circuit Work You Might Not Need

The cheapest computation is the one you never run. Eagerly computing values "in case the caller needs them" pays for work that will be thrown away when the caller takes the early-exit path. Two complementary patterns:
- **Short-circuit:** order boolean conditions cheap-first so expensive checks are skipped when an early condition fails. `cheap_check(x) and expensive_check(x)` is dramatically faster than `expensive_check(x) and cheap_check(x)` on the false-majority case.
- **Defer / lazy:** generate values on demand (generators, lazy properties), so a caller that only needs the first match doesn't pay for the rest of the collection.

**Incorrect (eager — compute everything up front):**

```python
def find_first_match(items, pattern):
    matches = [item for item in items if pattern.match(item.text)]   # O(n)
    return matches[0] if matches else None
# 1,000,000 items, match on item 5 → still scans all 1,000,000
```

**Correct (lazy — stop at the first match):**

```python
def find_first_match(items, pattern):
    return next((item for item in items if pattern.match(item.text)), None)
# Stops the moment the first matching item is yielded — typically O(position)
```

**Alternative (predicate ordering — cheap before expensive):**

```python
# Bad: expensive regex first, even though most items fail the cheap check
matches = [x for x in items if EXPENSIVE_RE.match(x.body) and x.score > 0]

# Good: cheap numeric check filters first; regex only runs on survivors
matches = [x for x in items if x.score > 0 and EXPENSIVE_RE.match(x.body)]
```

**When NOT to use this pattern:**
- When the values will all be consumed anyway — laziness adds bookkeeping for no benefit.
- When the lazy computation has side effects (DB queries, side-effecting iteration) that callers may not realize are deferred. Make it explicit.

Reference: [Python iterators and generators — lazy evaluation](https://docs.python.org/3/tutorial/classes.html#iterators)
