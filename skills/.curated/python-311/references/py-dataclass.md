---
title: Use dataclass for Data-Holding Classes
impact: LOW
impactDescription: reduces boilerplate by 80%
tags: py, dataclass, boilerplate, classes
---

## Use dataclass for Data-Holding Classes

Classes that primarily hold data require boilerplate `__init__`, `__repr__`, `__eq__`, etc. `@dataclass` generates these automatically with optimizations.

**Incorrect (manual boilerplate):**

```python
class User:
    def __init__(self, name: str, email: str, age: int, active: bool = True):
        self.name = name
        self.email = email
        self.age = age
        self.active = active

    def __repr__(self) -> str:
        return f"User(name={self.name!r}, email={self.email!r}, age={self.age}, active={self.active})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, User):
            return NotImplemented
        return (self.name, self.email, self.age, self.active) == (other.name, other.email, other.age, other.active)
```

**Correct (dataclass):**

```python
from dataclasses import dataclass

@dataclass
class User:
    name: str
    email: str
    age: int
    active: bool = True
    # __init__, __repr__, __eq__ auto-generated
```

**With slots for memory efficiency:**

```python
@dataclass(slots=True)  # Python 3.10+
class Point:
    x: float
    y: float
    z: float
```

**Frozen for immutability:**

```python
@dataclass(frozen=True)  # Hashable, immutable
class Coordinate:
    lat: float
    lng: float
```

Reference: [dataclasses documentation](https://docs.python.org/3/library/dataclasses.html)
