---
title: Use an Explicit Stack Instead of Deep Recursion
impact: HIGH
impactDescription: Prevents stack overflow on n > ~1,000; modest perf win from removing frames
tags: rec, stack-overflow, iterative, explicit-stack, tail-call
---

## Use an Explicit Stack Instead of Deep Recursion

Recursion is bounded by the language's call-stack depth — typically ~1,000 frames in CPython (default `sys.setrecursionlimit(1000)`), ~10,000 in V8. Algorithms with recursion depth proportional to input size (linked-list traversal, deeply nested JSON walking, naive tree walks on degenerate trees) crash at scale even when their Big-O is fine. Converting to an explicit stack/queue eliminates the depth limit and removes per-call frame overhead. Crucially, neither CPython nor mainstream JS engines perform tail-call optimization — writing tail-recursive code does **not** save the stack.

**Incorrect (recursion depth = list length — crashes at ~1,000 nodes):**

```python
def sum_list(node):
    if node is None:
        return 0
    return node.value + sum_list(node.next)
# 5,000-node list → RecursionError: maximum recursion depth exceeded
```

**Correct (iterative with explicit loop — unlimited depth):**

```python
def sum_list(node):
    total = 0
    while node is not None:
        total += node.value
        node = node.next
    return total
```

**Alternative (tree traversal with explicit stack):**

```python
def walk(root):
    stack = [root]
    while stack:
        node = stack.pop()
        process(node)
        stack.extend(node.children)        # pushes are O(1)
# Depth is now limited by heap, not call stack
```

**When NOT to use this pattern:**
- When recursion depth is provably O(log n) (balanced tree traversal) — stack depth is tiny and recursion is much clearer.
- In Scheme, Scala, or other languages with guaranteed tail-call optimization — tail-recursive form is idiomatic and safe.

Reference: [CPython `sys.setrecursionlimit` — default 1000, not optimized for deep recursion](https://docs.python.org/3/library/sys.html#sys.setrecursionlimit)
