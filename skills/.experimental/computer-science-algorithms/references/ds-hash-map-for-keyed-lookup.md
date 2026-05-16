---
title: Use A Hash Map For Keyed Lookup, Not Repeated Linear Scans
impact: CRITICAL
impactDescription: O(n) per lookup to O(1) average — typically 100-10000x at scale
tags: ds, hash-map, lookup, dict
---

## Use A Hash Map For Keyed Lookup, Not Repeated Linear Scans

A hash map (`dict` in Python, `unordered_map` in C++, `HashMap` in Java) gives O(1) average-case lookup, insert, and delete. Any code that repeatedly looks something up "by id" or "by name" by scanning a list is silently O(n·k) where it should be O(n+k). This is the most consequential data-structure switch in everyday code — the speedup is unbounded as the dataset grows.

Build the index once before the lookup loop; the build cost is O(n), and it's reused across every query.

**Incorrect (linear scan inside a loop — O(n·m)):**

```python
def attach_user_emails(orders, users):
    # For each order, scan all users to find the matching one.
    # n orders × m users = O(n·m).
    for order in orders:
        for u in users:
            if u["id"] == order["user_id"]:
                order["email"] = u["email"]
                break
    return orders
```

**Correct (build index once — O(n + m)):**

```python
def attach_user_emails(orders, users):
    # Build a {user_id: email} index in O(m), then O(1) per order lookup.
    email_by_id = {u["id"]: u["email"] for u in users}
    for order in orders:
        order["email"] = email_by_id.get(order["user_id"])
    return orders
```

**When NOT to use a hash map:**

- You need ordered iteration by key → use a balanced BST (`std::map`, `TreeMap`, `SortedDict`)
- You need range queries (`keys in [lo, hi]`) → BST or sorted array + binary search
- Keys are small integers in a known range → an array indexed by the integer is faster and cache-friendly
- Memory is critical and the dataset is small (< ~30 items) — a linear scan over contiguous memory may beat a hash table on cache effects

Reference: [CLRS Chapter 11 — Hash Tables](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
