---
title: Return Self from chainable and factory methods
tags: typing, self, fluent, classmethod
---

## Return Self from chainable and factory methods

Requires Python ≥ 3.11 (`typing.Self`, PEP 673).

A method that returns `self` or `cls(...)` annotated with the class's own name
is wrong under subclassing: `SubQuery.where(...)` comes back typed as the
parent, and every chained call after it loses the subclass's methods. The
pre-3.11 workaround — a bound `TypeVar` threaded through `self` — is correct
but three lines of ritual per class. `typing.Self` (3.11) is both the short and
the correct spelling: it binds to the runtime class, so subclasses chain and
factory classmethods construct as themselves.

**Incorrect (hardcoded name breaks subclasses; the TypeVar ritual is the verbose fix):**

```python
class QueryBuilder:
    def where(self, clause: str) -> "QueryBuilder":  # SubclassBuilder.where()
        self._clauses.append(clause)                 # returns the PARENT type
        return self
```

**Correct (binds to the runtime class):**

```python
from typing import Self

class QueryBuilder:
    def where(self, clause: str) -> Self:
        self._clauses.append(clause)
        return self

    @classmethod
    def from_table(cls, table: str) -> Self:
        return cls(base=f"SELECT * FROM {table}")
```

**Evidence of violation:** a method in the target that returns `self` or
`cls(...)` and is annotated with the enclosing class's own name (quoted or
not), or a `TypeVar` bound to the enclosing class used solely to type such
returns, on a Python floor ≥ 3.11. PASS: those returns are annotated `Self`.
N/A: Python floor < 3.11, no self/cls-returning methods in the target, or the
method genuinely returns the parent type by design (constructs the base class
explicitly — cite the constructor call).

Reference: [typing.Self (What's New in Python 3.11)](https://docs.python.org/3/whatsnew/3.11.html#typing)
