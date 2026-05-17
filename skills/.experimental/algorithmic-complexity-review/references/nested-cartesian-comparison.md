---
title: Group by Key Instead of Cartesian Comparison
impact: CRITICAL
impactDescription: O(n²) to O(n) — "find duplicates / similar pairs" is the canonical case
tags: nested, grouping, hashmap, deduplication, equivalence-class
---

## Group by Key Instead of Cartesian Comparison

"For each pair (i, j), check if they share property X" is O(n²) by construction — but the question is almost always equivalent to "group items by property X, then look at groups with more than one member," which is O(n). The pairwise version inspects n(n-1)/2 pairs; the grouped version walks the list once. The trick is recognizing that the inner condition (`a.email == b.email`) defines an equivalence class on a hashable key — and equivalence classes are exactly what `defaultdict(list)` builds for free.

**Incorrect (compare every pair — O(n²)):**

```python
duplicates = []
for i in range(len(records)):
    for j in range(i + 1, len(records)):
        if records[i].email == records[j].email:
            duplicates.append((records[i], records[j]))
# 10,000 records → ~50,000,000 comparisons
```

**Correct (group by key — O(n)):**

```python
from collections import defaultdict
buckets = defaultdict(list)
for r in records:
    buckets[r.email].append(r)              # O(1)
duplicates = [bucket for bucket in buckets.values() if len(bucket) > 1]
# 10,000 records → 10,000 inserts + one walk over buckets
```

**When NOT to use this pattern:**
- When the equivalence relation is non-transitive (e.g., "names within edit-distance 2 of each other") — grouping by key doesn't apply; reach for clustering, blocking, or locality-sensitive hashing.
- When you need every pair (not just the existence of one) for downstream pairwise scoring — then the n² work is intrinsic.

Reference: [NIST DADS — equivalence relation](https://xlinux.nist.gov/dads/HTML/equivalenceRel.html)
