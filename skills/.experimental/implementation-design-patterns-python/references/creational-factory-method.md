---
title: Use Factory Method to Decouple Object Creation from Concrete Classes
impact: HIGH
impactDescription: eliminates direct `Truck()`/`Ship()` constructor calls scattered through callers, isolates product instantiation so adding a new product type registers one class instead of editing every call site
tags: creational, factory-method, registry, polymorphic-creation, open-closed
---

## Use Factory Method to Decouple Object Creation from Concrete Classes

**Pattern intent:** define an interface for creating an object, but let the choice of concrete class be made elsewhere (a subclass or a registry). Callers consume products through a shared interface and never name the concrete type. In Python this usually collapses to a **registry dict** mapping a key to a product callable — no creator hierarchy required.

### Shapes to recognize

- Code littered with `Truck()`, `Ship()`, `Drone()` whose downstream handling is otherwise identical
- An `if kind == ...: return X()` ladder inside a constructor or helper that returns different classes
- A library that wants users to plug in their own product types without editing library code
- "I want to choose what gets instantiated by a string/config key, not a hard-coded class"

### Problem

A logistics app coupled to `Truck` struggles to add `Ship`: every site that builds a transport hard-codes the class, so each new mode (drone, freight) spreads the same conditional across the codebase and risks one branch drifting from the rest.

### Solution

Make all products honor a common `Protocol`, then resolve the concrete class through a registry keyed by a string. A `@register` decorator lets new products opt in at import time — adding one is a new class, not an edit to the resolver.

**Incorrect (caller branches on a string to pick a concrete class):**

```python
def make_transport(kind: str):
    if kind == "truck":
        return Truck()
    elif kind == "ship":
        return Ship()
    # Adding "drone" forces an edit here AND in every other place shaped like this.
    raise ValueError(kind)
```

**Correct (products register themselves; the factory resolves by key):**

```python
from typing import Protocol

class Transport(Protocol):
    def deliver(self) -> str: ...

_TRANSPORTS: dict[str, type[Transport]] = {}

def register(name: str):
    """Class decorator that adds a transport to the registry at import time."""
    def wrap(cls: type[Transport]) -> type[Transport]:
        _TRANSPORTS[name] = cls
        return cls
    return wrap

@register("truck")
class Truck:
    def deliver(self) -> str:
        return "delivered by road in a box"

@register("ship")
class Ship:
    def deliver(self) -> str:
        return "delivered by sea in a container"

def create_transport(name: str) -> Transport:
    try:
        return _TRANSPORTS[name]()
    except KeyError:
        raise ValueError(f"unknown transport: {name!r}") from None

# Adding a Drone is one new class + @register("drone") — create_transport never changes.
for name in ("truck", "ship"):
    print(create_transport(name).deliver())
```

**Output:**

```text
delivered by road in a box
delivered by sea in a container
```

**Alternative (class-based creator when the creator owns shared business logic that consumes the product):**

```python
from abc import ABC, abstractmethod

class Logistics(ABC):
    @abstractmethod
    def create_transport(self) -> Transport: ...

    def plan_delivery(self) -> str:          # shared logic; varies only by product
        return f"Planned: {self.create_transport().deliver()}"

class RoadLogistics(Logistics):
    def create_transport(self) -> Transport:
        return Truck()
```

### When to use

- The concrete type to build is unknown beforehand or chosen by config/plugin/string key
- You are building a framework and want third parties to extend the set of products
- A creator class holds business logic that consumes the product (use the class-based form)

### When NOT to use

- The product set is fixed, small, and trivially constructed — call the constructor directly
- You only ever build one variant — a registry or creator hierarchy is dead weight
- You need a *family* of related products that must match — reach for **Abstract Factory**

### Implementation Steps

1. Define a `Protocol` (or ABC) that all products implement
2. Create a module-level registry `dict[str, type[Product]]`
3. Add a `@register(key)` class decorator that records each product
4. Write `create_<thing>(key)` that looks up the class and instantiates it, raising on miss
5. Replace scattered constructor calls with the resolver; for a creator with shared logic, use an ABC with an abstract `create_*` method instead

### Pros

- Decouples callers from concrete classes — they depend only on the `Protocol`
- New product types register without editing the resolver (Open/Closed)
- Centralizes construction, so cross-cutting concerns (pooling, logging) live in one place

### Cons

- A registry adds indirection that a plain `dict` of constructors or direct `new` would not
- Import-time registration means the product module must be imported for its key to exist

### Related Patterns

- **Abstract Factory** — evolves from Factory Method when you need *families* of products that match
- **Prototype** — clone a configured instance instead of subclassing a creator
- **Template Method** — a factory method is often one step inside a template method
- **Singleton** — the registry/resolver itself is frequently a module-level singleton

Reference: [refactoring.guru/design-patterns/factory-method/python](https://refactoring.guru/design-patterns/factory-method/python/example)
