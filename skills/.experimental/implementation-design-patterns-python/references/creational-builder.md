---
title: Use Builder to Construct Complex Objects Step by Step
impact: HIGH
impactDescription: eliminates the telescoping-constructor smell (an `__init__` with 10+ positional parameters and many `None` defaults), prevents subclass explosion for parameter combinations, enables the same construction sequence to produce different representations
tags: creational, builder, dataclass, keyword-only, fluent-interface
---

## Use Builder to Construct Complex Objects Step by Step

**Pattern intent:** separate the construction of a complex object from its representation so the same steps can build different results. In Python the most common Builder motivation — too many constructor parameters — is solved outright by a **keyword-only `@dataclass`**. Reach for a fluent/staged builder only when construction is genuinely multi-step, ordered, or produces different representations.

### Shapes to recognize

- A constructor with 10+ parameters, most optional, callers passing `None, None, True, None`
- Subclasses created only to bake in a fixed parameter combination (`HouseWithPoolAndGarage`)
- Object assembly that proceeds in stages with validation between steps
- "I want readable construction and I keep forgetting which positional argument is which"

### Problem

A `House` needs walls, roof, optional pool, optional garden, optional garage. A single constructor balloons to a dozen positional parameters; callers can't tell `True, False, True` apart, and every new combination tempts a new subclass.

### Solution

For the "many optional fields" case, a keyword-only dataclass names every argument and supplies defaults — construction is self-documenting and combinations cost nothing. For staged assembly with validation or alternate outputs, use a fluent builder whose methods return `self`.

**Incorrect (telescoping constructor — positional soup):**

```python
class House:
    def __init__(self, walls, roof, has_pool=False, has_garden=False,
                 has_garage=False, floors=1, windows=4):
        ...

# Unreadable at the call site; which bool is which?
house = House("brick", "tile", True, False, True, 2, 12)
```

**Correct (keyword-only dataclass: named, defaulted, order-free):**

```python
from dataclasses import dataclass

@dataclass(kw_only=True)
class House:
    walls: str
    roof: str
    floors: int = 1
    windows: int = 4
    has_pool: bool = False
    has_garden: bool = False
    has_garage: bool = False

house = House(walls="brick", roof="tile", floors=2, windows=12, has_garage=True)
print(house)
```

**Output:**

```text
House(walls='brick', roof='tile', floors=2, windows=12, has_pool=False, has_garden=False, has_garage=True)
```

**Alternative (fluent builder when assembly is staged or yields different representations):**

```python
class HouseBuilder:
    def __init__(self) -> None:
        self._parts: dict[str, object] = {}

    def walls(self, material: str) -> "HouseBuilder":
        self._parts["walls"] = material
        return self                       # return self → chainable

    def pool(self) -> "HouseBuilder":
        self._parts["pool"] = True
        return self

    def build(self) -> House:
        return House(walls=self._parts.get("walls", "brick"), roof="tile",
                     has_pool=self._parts.get("pool", False))

villa = HouseBuilder().walls("stone").pool().build()
```

### When to use

- A constructor has many parameters, most optional (use the dataclass form)
- Construction is multi-step, ordered, or needs validation between steps (use the fluent form)
- The same construction sequence must produce different representations (e.g., a director driving JSON vs. XML output)

### When NOT to use

- The object has a handful of required fields — a plain `@dataclass` or constructor is enough
- There is exactly one representation and no staging — a keyword-only dataclass already wins
- You reach for a builder out of habit; in Python keyword arguments make most builders unnecessary

### Implementation Steps

1. Start with `@dataclass(kw_only=True)` and defaults — this resolves the common case
2. If construction is staged, define a builder class accumulating parts in instance state
3. Return `self` from each step method to allow chaining
4. Expose a terminal `build()` that validates and returns the finished product
5. Optionally add a *director* that encapsulates a common construction recipe over the builder

### Pros

- Construction is readable and order-independent (keyword arguments)
- New optional fields/combinations cost nothing — no subclass explosion
- A fluent builder isolates assembly logic and can enforce step ordering and validation

### Cons

- A fluent builder is more code than a dataclass and is rarely needed in Python
- A director adds another layer that only pays off when recipes are reused

### Related Patterns

- **Abstract Factory** — returns families of finished products; Builder assembles one product over steps
- **Factory Method** — a builder may use a factory method to pick the part implementations
- **Prototype** — clone a fully built object instead of re-running the construction steps
- **Composite** — builders frequently assemble Composite trees

Reference: [refactoring.guru/design-patterns/builder/python](https://refactoring.guru/design-patterns/builder/python/example)
