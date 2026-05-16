---
title: Watch Recursion Depth — Convert To Iteration Or Raise The Stack
impact: MEDIUM
impactDescription: prevents RecursionError / stack overflow on deep recursion
tags: divide, recursion, stack-depth, iteration
---

## Watch Recursion Depth — Convert To Iteration Or Raise The Stack

Python's default recursion limit is 1000; raising it via `sys.setrecursionlimit` doesn't raise the C stack, so the process can still segfault around 10⁴-10⁵ frames depending on platform. Other languages have similar limits (JVM default ~10⁴, Node ~10⁴). Recursive algorithms on long chains (linked lists, paths, deep trees) will crash silently in production. The fixes, in order of preference: (1) convert to iteration if the recursion is tail-recursive or has a single recursive call, (2) use an explicit stack for tree-shaped recursion, (3) raise the recursion limit only as a last resort.

The diagnostic: if the input size n is ≥ 10⁴ and the recursion depth scales linearly with n, you'll hit the limit on average inputs.

**Incorrect (recursive sum on a long linked list — crashes on n ≥ 1000):**

```python
class Node:
    __slots__ = ("val", "next")
    def __init__(self, val, nxt=None):
        self.val, self.next = val, nxt

def sum_list_recursive(head):
    # RecursionError when the list has > ~1000 nodes.
    if head is None: return 0
    return head.val + sum_list_recursive(head.next)
```

**Correct (iterative — no stack at all):**

```python
def sum_list(head: "Node | None") -> int:
    total = 0
    while head is not None:
        total += head.val
        head = head.next
    return total
```

**Tree DFS converted to explicit stack** (when you must recurse but inputs are deep):

```python
def dfs_iterative(root):
    # Each node is pushed once. No Python frames on the C stack.
    stack = [root]
    while stack:
        node = stack.pop()
        if node is None: continue
        # ... process node ...
        stack.append(node.right)
        stack.append(node.left)
```

**Raising the limit (last resort):**

```python
import sys, threading

def run_deep():
    sys.setrecursionlimit(10**6)
    # main work...

# Run on a thread with a larger C stack so the recursion limit is actually usable.
threading.stack_size(64 * 1024 * 1024)  # 64 MB
t = threading.Thread(target=run_deep)
t.start(); t.join()
```

**Mutual recursion** is especially dangerous: two functions calling each other halve the effective depth.

Reference: [Python docs — sys.setrecursionlimit](https://docs.python.org/3/library/sys.html#sys.setrecursionlimit)
