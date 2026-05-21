---
title: Use Visitor to Add Operations to Class Hierarchies Without Modifying Them
impact: LOW-MEDIUM
impactDescription: enables adding operations (export, validate, render) across a closed object hierarchy by writing one `@singledispatch` function instead of editing every node class, isolates each operation in one place rather than scattering it across the hierarchy
tags: behavioral, visitor, singledispatch, match-statement, double-dispatch
---

## Use Visitor to Add Operations to Class Hierarchies Without Modifying Them

**Pattern intent:** add new operations over a set of object types without modifying those types. The classic GoF form uses double dispatch (`accept`/`visit`); Python replaces it with `functools.singledispatch`, which dispatches one function on its first argument's type — or structural pattern matching (`match`) when all cases live in one function.

### Shapes to recognize

- An AST, scene graph, or shape hierarchy with several node types
- New operations (export to XML, type-check, render, compute area) needed across all of them
- Each new operation currently means adding a method to every node class — N x M growth
- "I need several unrelated operations over a closed set of types I'd rather not edit"

### Problem

A geometry library has `Circle` and `Rectangle`. Computing area, perimeter, and bounding box by adding a method to every shape for each operation spreads each operation across the hierarchy and forces editing every class whenever an operation is added.

### Solution

Write each operation as a single `@singledispatch` function with a registered implementation per type. Adding an operation is a new function; the shape classes never change. `match` is the alternative when you prefer one function with exhaustive cases.

**Incorrect (every new operation edits every node class):**

```python
class Circle:
    def area(self): ...
    def perimeter(self): ...    # adding bounding_box() edits Circle AND Rectangle AND ...
class Rectangle:
    def area(self): ...
    def perimeter(self): ...
```

**Correct (`@singledispatch`: one function per operation, dispatched by type):**

```python
from dataclasses import dataclass
from functools import singledispatch

@dataclass
class Circle:
    radius: float

@dataclass
class Rectangle:
    width: float
    height: float

@singledispatch
def area(shape: object) -> float:        # the operation lives outside the classes
    raise NotImplementedError(f"no area for {type(shape).__name__}")

@area.register
def _(shape: Circle) -> float:
    return 3.14159 * shape.radius ** 2

@area.register
def _(shape: Rectangle) -> float:
    return shape.width * shape.height

shapes: list[object] = [Circle(1.0), Rectangle(2.0, 3.0)]
print([round(area(s), 2) for s in shapes])   # adding perimeter() touches no shape class
```

**Output:**

```text
[3.14, 6.0]
```

**Alternative (structural pattern matching when one function suits all cases):**

```python
def area(shape: object) -> float:
    match shape:
        case Circle(radius=r):
            return 3.14159 * r ** 2
        case Rectangle(width=w, height=h):
            return w * h
        case _:
            raise NotImplementedError(shape)
```

### When to use

- You must add many unrelated operations over a stable set of types
- You cannot or prefer not to edit the element classes for each new operation
- An operation should live in one place rather than be smeared across the hierarchy

### When NOT to use

- The set of types changes often — every new type means updating every operation
- There is only one operation across a small hierarchy — a method on each type is simpler
- The operation needs private state of the elements that dispatch can't reach cleanly

### Implementation Steps

1. Keep the element types as plain (data)classes — ideally dataclasses
2. Write each operation as a `@singledispatch` function with a fallback that raises
3. Register one implementation per concrete type with `@operation.register`
4. Call the operation as a normal function; dispatch picks the right implementation
5. Prefer `match` when you'd rather keep all cases in one exhaustive function

### Pros

- Open/Closed for operations: add an operation without touching the types
- Each operation is isolated in one function (Single Responsibility)
- `singledispatch` and `match` avoid the GoF `accept`/`visit` boilerplate entirely

### Cons

- Adding a new *type* requires updating every operation
- Free functions can't reach private element state the way methods can
- `singledispatch` keys on the first argument's runtime type only

### Related Patterns

- **Composite** — Visitor commonly walks a Composite tree applying an operation per node
- **Iterator** — traverse with an Iterator while applying a Visitor at each element
- **Command** — both externalize behavior; Visitor dispatches across many element types
- **Strategy** — both inject behavior; Visitor selects by element type, Strategy by caller choice

Reference: [refactoring.guru/design-patterns/visitor/python](https://refactoring.guru/design-patterns/visitor/python/example)
