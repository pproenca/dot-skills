---
title: Pipe Through Generators Instead of Materializing Intermediate Lists
impact: MEDIUM
impactDescription: O(n) intermediate storage to O(1) — also enables early exit
tags: space, generator, lazy, pipeline, iterator
---

## Pipe Through Generators Instead of Materializing Intermediate Lists

Chaining `map(...)`, `filter(...)`, then `sum(...)` over a list with eager evaluation builds a new full list at each stage — three passes over n items, each allocating n elements. A generator pipeline (Python generator expressions, JS iterator helpers, Java `Stream`, Go channels) walks the data once, lazily, producing each result on demand. Memory drops from O(n) of intermediate allocations to O(1), and short-circuit consumers (`next`, `any`, `all`, `find`) can stop as soon as the answer is known.

**Incorrect (materialized intermediates — O(n) extra memory per stage):**

```python
squared = [x * x for x in numbers]            # allocates list of size n
positives = [x for x in squared if x > 0]     # allocates again
total = sum(positives)                         # walks again
# 3 × n allocations + 3 passes
```

**Correct (generator pipeline — O(1) memory, one pass):**

```python
total = sum(x * x for x in numbers if x * x > 0)
# Single fused pass, no intermediate list allocation
```

**Alternative (generator function with early termination):**

```python
def positive_squares(nums):
    for x in nums:
        sq = x * x
        if sq > 0:
            yield sq

# Caller can stop as soon as a condition is met
first_big = next(sq for sq in positive_squares(numbers) if sq > 1_000_000)
```

**Alternative (JS — generator function):**

```javascript
function* positiveSquares(nums) {
  for (const x of nums) {
    const sq = x * x;
    if (sq > 0) yield sq;
  }
}
// Memory: O(1). And: stops early if consumer breaks
```

**When NOT to use this pattern:**
- When you need to iterate the same data multiple times — generators are single-pass; materialize the result if you'll reuse it.
- When you need indexed/random access — generators only support sequential iteration.

Reference: [PEP 289 — Generator Expressions](https://peps.python.org/pep-0289/)
