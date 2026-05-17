---
title: Allocate Collections With the Known Final Length
impact: LOW-MEDIUM
impactDescription: 2-5× constant-factor speedup; avoids GC pressure from repeated reallocs
tags: build, preallocation, capacity, gc-pressure, micro-optimization
---

## Allocate Collections With the Known Final Length

Dynamic arrays and hashmaps grow by doubling capacity when full — each growth allocates a new backing array and copies existing entries. The amortized cost is O(1) per insert, but the constant factor includes several reallocations and the GC pressure of orphaned old buffers. When the final size is known up-front (you're transforming a list of known length, parsing a known number of records), pre-sizing the container eliminates the reallocations and the GC work, typically saving 2-5× on hot paths. In Python this matters most for `dict`; in Java for `ArrayList`/`HashMap`; in Go for `make([]T, 0, n)`.

**Incorrect (default capacity — multiple grow-and-copy cycles):**

```go
// Go: default capacity grows from 1 → 2 → 4 → 8 → 16 → ... reallocating each time
results := []int{}
for _, x := range data {       // len(data) == 100_000
    results = append(results, transform(x))
}
// ~17 reallocations + copies of growing backing arrays
```

**Correct (pre-allocate with known capacity):**

```go
results := make([]int, 0, len(data))   // capacity = len(data), length = 0
for _, x := range data {
    results = append(results, transform(x))
}
// Zero reallocations
```

**Alternative (Python `dict` — comprehension is faster than per-key assignment):**

```python
# Slower: explicit loop pays bytecode dispatch per insert
result = {}
for k, v in pairs:
    result[k] = transform(v)

# Faster: comprehension uses a tight bytecode loop (BUILD_MAP / MAP_ADD)
# and avoids the per-iteration STORE_NAME of the dict. Note: CPython does
# NOT pre-size from generator length, but the loop overhead is lower.
result = {k: transform(v) for k, v in pairs}
```

**Alternative (Java — pre-size HashMap to avoid rehashing):**

```java
// HashMap default capacity is 16, rehashes at 75% load → grows for any data
Map<Integer, User> map = new HashMap<>(items.size() * 4 / 3 + 1);
for (User u : items) map.put(u.id, u);
```

**When NOT to use this pattern:**
- When the final size is not known and you'd have to estimate badly — the dynamic growth is exactly designed for this case.
- When the data is small (< 100 items) — the savings are immeasurable.

Reference: [Go blog — `slices` and `append` semantics](https://go.dev/blog/slices)
