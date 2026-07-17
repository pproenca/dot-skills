---
title: Use dataclasses instead of hand-written init, repr, and eq
tags: model, dataclass, boilerplate, value-objects
---

## Use dataclasses instead of hand-written init, repr, and eq

A class whose `__init__` copies parameters onto attributes — plus the
`__repr__` and `__eq__` someone remembers to add later, or forgets — is
generated code written by hand. `@dataclass` produces all three correctly and
consistently, `slots=True` removes the per-instance `__dict__` (smaller
instances, attribute typos become `AttributeError`), and `frozen=True` turns a
value object hashable and immutable. Hand-written versions are longer, drift
when fields change (the field added to `__init__` but not `__eq__` is a classic
silent bug), and hide the one place the class *does* do real work.

**Incorrect (three methods that restate the field list, already out of sync):**

```python
class ShippingQuote:
    def __init__(self, carrier: str, cents: int, eta_days: int) -> None:
        self.carrier = carrier
        self.cents = cents
        self.eta_days = eta_days

    def __repr__(self) -> str:
        return f"ShippingQuote({self.carrier!r}, {self.cents})"  # eta_days missing

    def __eq__(self, other: object) -> bool:
        return isinstance(other, ShippingQuote) and self.carrier == other.carrier
        # cents and eta_days silently ignored
```

**Correct (the field list stated once):**

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class ShippingQuote:
    carrier: str
    cents: int
    eta_days: int
```

**Evidence of violation:** a class in the target whose `__init__` consists of
parameter-to-attribute assignments (trivial defaults included) with no
validation, derivation, or resource acquisition — or a hand-written
`__repr__`/`__eq__`/`__hash__` that reproduces field-based semantics — and no
`@dataclass` (or equivalent generator such as `NamedTuple`, `attrs`, or a
pydantic model). PASS: the class is a dataclass/NamedTuple/pydantic model, or
its `__init__` does cited real work beyond assignment. N/A: no such class in
the target. If only *some* fields need real handling, `__post_init__` or
`field(default_factory=...)` covers them — cite that as the fix, not as a
carve-out for keeping the boilerplate.

Reference: [dataclasses — Python documentation](https://docs.python.org/3/library/dataclasses.html)
