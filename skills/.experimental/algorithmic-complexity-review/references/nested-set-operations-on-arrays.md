---
title: Use Sets for Intersection, Union, and Difference
impact: CRITICAL
impactDescription: O(n*m) to O(n+m) — typical 100× speedup on large lists
tags: nested, set-operations, intersection, union, difference
---

## Use Sets for Intersection, Union, and Difference

Computing `A ∩ B`, `A ∪ B`, or `A \ B` with list-based membership tests (`x in list`, `Array.includes`) is O(|A| × |B|). Converting the inner collection to a hash set once is O(|B|); subsequent membership tests are O(1), and the whole operation drops to O(|A| + |B|). Python, JavaScript, Java, and Go all expose hash sets in the standard library with this exact use case in mind — there is essentially no reason to compute set operations against an unhashed list.

**Incorrect (list-based membership — O(n*m)):**

```python
# Intersection: items in both A and B
common = [x for x in list_a if x in list_b]   # `x in list_b` scans list_b
# Difference: items in A not in B
only_in_a = [x for x in list_a if x not in list_b]
```

**Correct (hash set — O(n+m)):**

```python
b_set = set(list_b)                           # O(m) once
common = [x for x in list_a if x in b_set]    # O(1) per check
only_in_a = [x for x in list_a if x not in b_set]
```

**Alternative (when order doesn't matter):**

```python
common = set(list_a) & set(list_b)            # O(n + m)
only_in_a = set(list_a) - set(list_b)
```

**When NOT to use this pattern:**
- When elements are unhashable (e.g., dicts, lists). Either extract a hashable key (`tuple(sorted(d.items()))`) or accept the quadratic cost when n is small.
- When you need duplicates preserved — sets collapse them; use `collections.Counter` for multiset semantics.

Reference: [Python Time Complexity — set operations](https://wiki.python.org/moin/TimeComplexity)
