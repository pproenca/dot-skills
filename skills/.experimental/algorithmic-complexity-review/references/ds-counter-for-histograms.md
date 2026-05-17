---
title: Use Counter / Multiset for Frequency Counting
impact: MEDIUM-HIGH
impactDescription: O(n²) to O(n) — and replaces 5-10 lines with one
tags: ds, counter, multiset, histogram, frequency
---

## Use Counter / Multiset for Frequency Counting

Frequency counting ("how many times does each value appear?") and the related most-common / top-k questions are common enough that the standard library has a primitive for them: `collections.Counter` (Python), `MultiSet` in Apache Commons (Java), `lodash.countBy` / `Map` (JS). The manual implementation — initialize a dict, check `if key not in counts`, increment — works but is verbose, easy to get wrong (forgetting the default), and slower than the C-optimized Counter. The Counter primitive also exposes `most_common(k)`, which uses a bounded heap internally and is the right structure for top-k frequency questions.

**Incorrect (manual increment — O(n) but error-prone, no top-k helper):**

```python
counts = {}
for word in words:
    if word in counts:
        counts[word] += 1
    else:
        counts[word] = 1

# Now find the top 10 words — manual sort, full O(n log n):
top_10 = sorted(counts.items(), key=lambda kv: -kv[1])[:10]
```

**Correct (`Counter`):**

```python
from collections import Counter
counts = Counter(words)            # O(n), C-optimized
top_10 = counts.most_common(10)    # O(n log 10) via internal heap
```

**Alternative (JavaScript):**

```javascript
// Map preserves insertion order, supports any key type
const counts = new Map();
for (const w of words) counts.set(w, (counts.get(w) ?? 0) + 1);
```

**When NOT to use this pattern:**
- When you need a sliding-window count over a stream — a `Counter` rebuilt per window is wasteful; maintain it incrementally with add/remove deltas.

Reference: [Python `collections.Counter` — frequency dictionary subclass](https://docs.python.org/3/library/collections.html#collections.Counter)
