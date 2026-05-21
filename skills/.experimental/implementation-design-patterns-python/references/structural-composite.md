---
title: Use Composite to Treat Trees and Leaves Uniformly
impact: HIGH
impactDescription: eliminates `isinstance` branching throughout traversal code, enables recursive operations across an object tree through one interface, lets clients work with arbitrarily nested structures without tracking depth
tags: structural, composite, tree, recursion, protocol
---

## Use Composite to Treat Trees and Leaves Uniformly

**Pattern intent:** compose objects into trees and let clients treat individual objects (leaves) and compositions (branches) through the same interface. Each branch implements the operation by recursing over its children. In Python a shared `Protocol` plus a recursive method (or `__iter__`) is all it takes.

### Shapes to recognize

- A tree: files/folders, UI widgets/containers, org chart, expression AST, nested groups
- Traversal code full of `isinstance(node, Folder)` to decide whether to recurse
- An operation (size, render, total price) that must apply to both single items and groups
- "I want to call one method on the root and have it walk the whole structure"

### Problem

A file system computes total size. A folder contains files *and* other folders. Code that special-cases each kind — `if isinstance(node, File): ... elif isinstance(node, Folder): ...` — repeats the branch at every operation and breaks when a new node type appears.

### Solution

Define one `Protocol` with the operation (`size`). Leaves implement it directly; composites implement it by summing the result over their children. Clients call the operation on any node without knowing whether it's a leaf or a branch.

**Incorrect (`isinstance` branching at every traversal):**

```python
def total_size(node) -> int:
    if isinstance(node, File):
        return node.bytes
    elif isinstance(node, Folder):
        return sum(total_size(child) for child in node.children)
    # Add a Symlink node type and every function shaped like this must change.
    raise TypeError(node)
```

**Correct (leaf and branch share one interface; branch recurses):**

```python
from typing import Protocol

class Node(Protocol):
    def size(self) -> int: ...

class File:
    def __init__(self, name: str, num_bytes: int) -> None:
        self.name, self._bytes = name, num_bytes
    def size(self) -> int:
        return self._bytes                       # leaf: base case

class Folder:
    def __init__(self, name: str, children: list[Node]) -> None:
        self.name, self.children = name, children
    def size(self) -> int:
        return sum(child.size() for child in self.children)   # branch: recurse

root = Folder("/", [
    File("a.txt", 100),
    Folder("sub", [File("b.txt", 200), File("c.txt", 50)]),
])
print(root.size())                               # one call walks the whole tree
```

**Output:**

```text
350
```

### When to use

- Your data forms a part-whole hierarchy (trees of arbitrary depth)
- Clients should treat single objects and groups of objects identically
- Operations should recurse over the structure without callers managing the recursion

### When NOT to use

- The structure is flat — a list and a loop are clearer than a tree abstraction
- Leaves and branches need genuinely different interfaces — forcing one interface adds empty methods
- The hierarchy is fixed and small with one operation — a recursive function with `match` may read better

### Implementation Steps

1. Model the domain as a tree of leaves and containers
2. Declare a `Protocol` with the operations clients call on any node
3. Implement leaves so the operation returns their own value (base case)
4. Implement composites so the operation aggregates results over children (recursive case)
5. Optionally add `__iter__` so the tree supports `for node in tree` traversal

### Pros

- Clients work with arbitrarily complex trees through one interface
- New node types slot in without changing traversal code (Open/Closed)
- Recursion lives inside the structure, not scattered across `isinstance` checks

### Cons

- A single shared interface can be awkward when leaf and branch behavior diverge sharply
- Type checks for "is this a leaf?" creep back if clients need to add children only to branches

### Related Patterns

- **Iterator** — traverses a Composite without exposing its structure (`__iter__`/generators)
- **Visitor** — applies new operations across a Composite without editing the node classes
- **Decorator** — also recursive wrapping, but adds responsibilities rather than aggregating children
- **Builder** — frequently assembles Composite trees

Reference: [refactoring.guru/design-patterns/composite/python](https://refactoring.guru/design-patterns/composite/python/example)
