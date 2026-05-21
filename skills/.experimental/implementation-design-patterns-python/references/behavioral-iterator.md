---
title: Use Iterator to Traverse Collections Without Exposing Their Internals
impact: HIGH
impactDescription: hides a collection's representation behind the iterator protocol (list, tree, graph, stream all look the same to `for`), enables multiple independent traversals, eliminates duplicated traversal code across the app
tags: behavioral, iterator, generator, yield, iter-protocol
---

## Use Iterator to Traverse Collections Without Exposing Their Internals

**Pattern intent:** traverse a collection without exposing its underlying representation. Python builds this into the language: implement `__iter__` (ideally as a **generator** using `yield`) and the object works with `for`, `list()`, `sum()`, `in`, unpacking, and every itertools helper.

### Shapes to recognize

- A custom collection (tree, graph, ring buffer, paginated API) clients must walk
- Callers reaching into `.children`/`._items` and writing their own recursion
- The same traversal logic (depth-first walk, page fetching) copied in several places
- "I want `for x in my_structure` to just work, hiding how it's stored"

### Problem

A tree exposes its `children` list, so every caller that needs to walk it writes its own recursion over the internal structure. Change the storage and all that traversal code breaks; two callers walk it inconsistently.

### Solution

Implement `__iter__` as a generator that yields elements in traversal order and uses `yield from` to recurse. Callers use ordinary `for`/`list()` and never see the internal layout; each `for` gets a fresh, independent traversal.

**Incorrect (callers recurse over exposed internals):**

```python
def walk(node, out):
    out.append(node.value)
    for child in node.children:      # caller knows it's a list of children
        walk(child, out)             # every call site re-implements this
    return out
```

**Correct (`__iter__` generator hides the structure):**

```python
from collections.abc import Iterator
from dataclasses import dataclass, field

@dataclass
class TreeNode:
    value: int
    children: list["TreeNode"] = field(default_factory=list)

    def __iter__(self) -> Iterator[int]:
        yield self.value             # depth-first, computed lazily
        for child in self.children:
            yield from child         # delegate to the child's own __iter__

tree = TreeNode(1, [TreeNode(2, [TreeNode(4)]), TreeNode(3)])

print(list(tree))                    # for, sum, any, unpacking all work now
print(4 in tree, sum(tree))
```

**Output:**

```text
[1, 2, 4, 3]
True 10
```

### When to use

- A collection's internal structure should stay hidden from callers
- You want several independent traversals over the same collection
- The traversal is non-trivial (tree, graph, lazy/paginated source) and shouldn't be duplicated

### When NOT to use

- The data is already a `list`/`dict`/`set` — iterate it directly, don't wrap it
- Callers legitimately need index access and mutation — an iterator hides what they need
- A one-off traversal in a single place — a local generator function is enough

### Implementation Steps

1. Decide the traversal order (depth-first, breadth-first, sorted, paginated)
2. Implement `__iter__` as a generator that `yield`s elements in that order
3. Use `yield from` to delegate into sub-collections recursively
4. Add a separate generator method per order if you need more than one (e.g., `breadth_first()`)
5. Rely on the protocol — `for`, `list()`, `sum()`, `in`, and itertools all work for free

### Pros

- Hides representation; callers depend only on the iterator protocol (Single Responsibility)
- Generators make each traversal lazy and independent
- Eliminates duplicated traversal code and works with the whole standard library

### Cons

- For trivially simple collections, a custom iterator is overkill
- Generator state is single-pass; you re-call `__iter__` for a fresh walk

### Related Patterns

- **Composite** — Iterators are the natural way to traverse Composite trees
- **Visitor** — pair an Iterator (traversal) with a Visitor (operation at each node)
- **Factory Method** — `__iter__` is a factory method that produces the iterator
- **Memento** — can capture an iterator's position to resume traversal

Reference: [refactoring.guru/design-patterns/iterator/python](https://refactoring.guru/design-patterns/iterator/python/example)
