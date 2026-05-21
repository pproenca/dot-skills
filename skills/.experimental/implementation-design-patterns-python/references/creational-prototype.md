---
title: Use Prototype to Clone Objects Without Coupling to Concrete Classes
impact: MEDIUM
impactDescription: enables copying complex pre-configured objects through `copy.deepcopy`/`dataclasses.replace` without a hand-written copy constructor, preserves nested mutable state automatically, removes the per-class copy code that silently rots when a field is added
tags: creational, prototype, copy-deepcopy, dataclasses-replace, cloning
---

## Use Prototype to Clone Objects Without Coupling to Concrete Classes

**Pattern intent:** copy existing objects without making the caller depend on their concrete classes. Python builds this in: `copy.copy`/`copy.deepcopy` clone any object, and `dataclasses.replace` produces a modified copy of a dataclass. You rarely write a `clone()` method — you override `__copy__`/`__deepcopy__` only when default copying is wrong.

### Shapes to recognize

- A hand-written "copy constructor" that lists every field — and breaks the moment a field is added
- Cloning needed for an object whose concrete class the caller shouldn't have to know
- A configured instance (default settings, pre-wired graph) that's expensive to rebuild from scratch
- "I need another one just like this, but with one value changed"

### Problem

A pre-configured object — a chart with styling, scales, and a populated dataset — must be duplicated so a variant can be tweaked. A manual copy constructor has to know every field, reaches into nested mutable state by hand, and rots whenever the class gains a field.

### Solution

Use `copy.deepcopy` to clone the whole object graph independent of its class, and `dataclasses.replace` when you want a copy with a few fields changed. Both work through a uniform interface, so callers never name the concrete type.

**Incorrect (manual copy constructor — rots and shares nested state):**

```python
class Chart:
    def __init__(self, title, series, axes):
        self.title = title
        self.series = series
        self.axes = axes

    def copy(self) -> "Chart":
        # Forgot deepcopy: the clone shares `series`/`axes` with the original.
        # Add a field later and this silently stops copying it.
        return Chart(self.title, self.series, self.axes)
```

**Correct (`deepcopy` clones the graph; `replace` tweaks a copy):**

```python
import copy
from dataclasses import dataclass, field, replace

@dataclass
class Chart:
    title: str
    series: list[int] = field(default_factory=list)
    axes: dict[str, str] = field(default_factory=dict)

original = Chart(title="Revenue", series=[1, 2, 3], axes={"x": "month"})

twin = copy.deepcopy(original)        # fully independent clone, any class, any depth
twin.series.append(4)                 # does not touch `original.series`

variant = replace(original, title="Revenue (EU)")   # copy with one field changed

print(original.series, twin.series)
print(variant.title, "| shares series with original:", variant.series is original.series)
```

**Output:**

```text
[1, 2, 3] [1, 2, 3, 4]
Revenue (EU) | shares series with original: True
```

Note the contrast: `deepcopy` produces a fully independent clone, while `dataclasses.replace` is a **shallow** copy — any field you don't override (here `series`) is shared with the original. Use `deepcopy` (or override the mutable fields in the `replace` call) when you need the copy's nested state to be independent.

### When to use

- You need copies of objects whose concrete class the caller should not depend on
- Building a fresh instance is costlier than copying a configured one
- You want a near-identical object with a few values changed (`dataclasses.replace`)

### When NOT to use

- The object is cheap and simple to construct directly — copying buys nothing
- The object holds non-copyable resources (open sockets, file handles, locks) — implement `__deepcopy__` to handle them or avoid cloning
- A shallow share is actually what you want — `copy.copy` or a direct reference is clearer than deepcopy

### Implementation Steps

1. Reach for `copy.deepcopy(obj)` for an independent clone of the whole graph
2. Reach for `dataclasses.replace(obj, field=value)` to copy-with-changes a dataclass
3. Use `copy.copy(obj)` when a shallow copy (shared nested objects) is intended
4. Override `__deepcopy__`/`__copy__` only when default copying mishandles a field (resources, caches, back-references)
5. Drop any hand-written copy constructors that duplicate this for free

### Pros

- Clone any object without knowing its concrete class
- `deepcopy` handles arbitrary nesting and cycles automatically
- `replace` makes copy-with-changes a single expression and keeps immutability intact

### Cons

- `deepcopy` is slow on large graphs and copies things you may not want copied
- Objects holding external resources need custom `__deepcopy__` or cannot be cloned safely

### Related Patterns

- **Abstract Factory** — can use prototypes (clone) instead of instantiating concrete classes
- **Factory Method** — a factory may return a clone of a stored prototype
- **Composite / Decorator** — deep cloning a Composite tree relies on Prototype-style copying
- **Memento** — both snapshot state; Memento restores history, Prototype produces independent twins

Reference: [refactoring.guru/design-patterns/prototype/python](https://refactoring.guru/design-patterns/prototype/python/example)
