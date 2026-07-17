---
title: Replace repeated state literals with StrEnum
tags: disp, strenum, enum, stringly-typed
---

## Replace repeated state literals with StrEnum

Requires Python ≥ 3.11 for `StrEnum` (a plain `Enum` satisfies the rule on
older floors).

A status or kind modeled as a bare string literal repeated across the codebase
has no home: a typo in one comparison site (`"cancelled"` vs `"canceled"`) is a
silent permanent-false branch, the set of valid states exists nowhere, and type
checkers can verify none of it. `enum.StrEnum` fixes this without a migration —
members compare equal to their string values, so JSON serialization, database
columns, and existing string comparisons keep working while the state set
becomes a checkable, greppable type.

```python
from enum import StrEnum

class OrderStatus(StrEnum):
    PENDING = "pending"
    PAID = "paid"
    SHIPPED = "shipped"
    CANCELED = "canceled"

def can_refund(order: Order) -> bool:
    return order.status in (OrderStatus.PAID, OrderStatus.SHIPPED)

# StrEnum members ARE strings — json.dumps({"status": OrderStatus.PAID})
# produces {"status": "paid"} with no custom encoder.
```

**Evidence of violation:** the same bare string literal denoting a state, kind,
or mode — assigned to a field, compared with `==`/`in`, or matched in a `case`
— at **3 or more distinct sites** in the target, with no enum (or
`Literal`-typed alias) declaring the value set. PASS: the value set is declared
once as a `StrEnum`/`Enum` (or a `Literal[...]` union type used in every
annotation) and sites reference it — cite the declaration. N/A: the literals
are user-facing text, log messages, dict keys, or external protocol constants
used at a single boundary site. Fewer than 3 sites in the target is N/A, but
count sites in unchanged code too when the diff adds a new one — adding the
fourth comparison to an existing stringly-typed state is a FAIL with the fix
being the enum introduction.

Reference: [enum.StrEnum — Python documentation](https://docs.python.org/3/library/enum.html#enum.StrEnum)
