---
title: Use A Set For Uniqueness And Membership, Not A List
impact: CRITICAL
impactDescription: O(n) per membership check to O(1) — dedup goes from O(n²) to O(n)
tags: ds, set, membership, dedup
---

## Use A Set For Uniqueness And Membership, Not A List

A set tracks "have I seen this value?" in O(1) average time. Using a list for the same purpose makes every check O(n) and every dedup pass O(n²). The two operations look identical in code (`if x in container`) but have wildly different costs — the container type is the *only* difference, and it matters for every single iteration.

Reach for a set whenever the question is "is this value present?" or "give me the distinct values." Reach for a `dict` if you also need a payload per key.

**Incorrect (dedup via list — O(n²)):**

```python
def unique_preserve_order(items: list[int]) -> list[int]:
    # `x in seen` is O(|seen|), called n times → O(n²)
    seen: list[int] = []
    out: list[int] = []
    for x in items:
        if x not in seen:
            seen.append(x)
            out.append(x)
    return out
```

**Correct (dedup via set — O(n)):**

```python
def unique_preserve_order(items: list[int]) -> list[int]:
    # `x in seen` is O(1) average. Set tracks membership; list preserves order.
    seen: set[int] = set()
    out: list[int] = []
    for x in items:
        if x not in seen:
            seen.add(x)
            out.append(x)
    return out
```

**One-liner when order doesn't matter:**

```python
def unique(items: list[int]) -> list[int]:
    return list(set(items))  # O(n), no order guarantee
```

**Watch out:**

- Set elements must be hashable. For lists of dicts/lists, use `frozenset`/`tuple` keys or a `dict[hashable_id, item]`.
- Python's `set` iteration order is insertion order in CPython 3.7+ for `dict`, but **not** for `set` — don't rely on it.

Reference: [Python docs — set](https://docs.python.org/3/library/stdtypes.html#set)
