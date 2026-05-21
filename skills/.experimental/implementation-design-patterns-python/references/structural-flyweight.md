---
title: Use Flyweight to Share Common State Across Many Objects
impact: LOW-MEDIUM
impactDescription: cuts memory when spawning millions of similar objects (game particles, map tiles, glyphs) by sharing one immutable intrinsic-state object via a cache and passing variable extrinsic state per call, plus `__slots__` to drop the per-instance `__dict__`
tags: structural, flyweight, slots, lru-cache, memory-sharing
---

## Use Flyweight to Share Common State Across Many Objects

**Pattern intent:** fit more objects into memory by sharing the parts that are identical across many of them (intrinsic state) and keeping only the parts that differ per object (extrinsic state). In Python this is a cached factory for the shared object (`functools.lru_cache`) plus `__slots__` on the many small objects.

### Shapes to recognize

- Millions of near-identical objects: forest trees, particle effects, map tiles, text glyphs
- Each object stores a full copy of heavy data (mesh, texture, sprite) that's identical across thousands of them
- Memory blows up though most fields repeat
- "I have 1,000,000 trees and only 3 distinct tree types"

### Problem

A game spawns a million trees. Each `Tree` stores its name, mesh, and texture — but there are only three tree types, so the same megabytes of mesh/texture data are duplicated across hundreds of thousands of instances, exhausting RAM.

### Solution

Split the data: immutable shared state (name, mesh, texture) goes into a `TreeType` flyweight produced by a cached factory, so identical arguments return the *same* object. Per-instance variable state (x, y) stays on the `Tree`, which uses `__slots__` to avoid a per-instance `__dict__`.

**Incorrect (every instance duplicates the heavy shared data):**

```python
class Tree:
    def __init__(self, x, y, name, mesh, texture):
        self.x, self.y = x, y
        self.name, self.mesh, self.texture = name, mesh, texture   # copied 1,000,000x

forest = [Tree(i, i, "oak", "oak.obj<5MB>", "oak.png<2MB>") for i in range(1_000_000)]
```

**Correct (shared intrinsic state via a cached factory; extrinsic state per instance):**

```python
from dataclasses import dataclass
from functools import lru_cache

@dataclass(frozen=True, slots=True)
class TreeType:                       # intrinsic, immutable, shared
    name: str
    mesh: str
    texture: str

@lru_cache(maxsize=None)
def tree_type(name: str, mesh: str, texture: str) -> TreeType:
    return TreeType(name, mesh, texture)   # identical args -> identical object

class Tree:
    __slots__ = ("x", "y", "type")   # no per-instance __dict__ -> smaller objects
    def __init__(self, x: int, y: int, type_: TreeType) -> None:
        self.x, self.y, self.type = x, y, type_

oak = tree_type("oak", "oak.obj", "oak.png")
forest = [Tree(i, i, oak) for i in range(1_000_000)]
print(forest[0].type is forest[999_999].type)   # one TreeType shared by all
```

**Output:**

```text
True
```

### When to use

- You spawn a very large number of objects and run into memory pressure
- A large share of each object's state is identical across instances and is immutable
- The variable (extrinsic) state can be passed in or stored cheaply per instance

### When NOT to use

- Object counts are modest — the cache and the intrinsic/extrinsic split add complexity for no gain
- The "shared" state is actually mutated per object — flyweights must be immutable
- `__slots__` alone solves your memory problem — apply it first and measure before introducing a cache

### Implementation Steps

1. Profile to confirm memory is the bottleneck and many objects share state
2. Split fields into intrinsic (shared, immutable) and extrinsic (per-instance, variable)
3. Move intrinsic fields into a frozen `dataclass(slots=True)` flyweight
4. Build flyweights through a `functools.lru_cache`d factory so duplicates collapse to one object
5. Add `__slots__` to the many small objects and pass the flyweight in

### Pros

- Large memory savings when many objects share immutable state
- The cache guarantees one object per distinct intrinsic state
- `__slots__` shrinks every instance independently of the sharing

### Cons

- Trades CPU (cache lookups, passing extrinsic state) for memory
- Splitting state complicates the model and is wasted effort below large object counts
- Flyweights must stay immutable, which constrains the design

### Related Patterns

- **Singleton** — a flyweight cache may hold one object per state; Singleton holds exactly one overall
- **Composite** — flyweights often serve as shared leaf nodes in a Composite tree
- **Factory Method** — the cached factory function is how flyweights are obtained
- **Prototype** — both manage object identity/copies; Flyweight shares rather than clones

Reference: [refactoring.guru/design-patterns/flyweight/python](https://refactoring.guru/design-patterns/flyweight/python/example)
