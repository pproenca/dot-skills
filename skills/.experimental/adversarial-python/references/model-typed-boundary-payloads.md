---
title: Declare a shape for external payloads at the boundary
tags: model, typeddict, boundaries, payloads
---

## Declare a shape for external payloads at the boundary

Requires Python ≥ 3.11 for `Required`/`NotRequired` (a total/partial
`TypedDict` split or a dataclass satisfies the rule on older floors).

An external payload — request JSON, webhook body, queue message — that stays a
`dict[str, Any]` while it travels inward forces every downstream function to
re-discover its shape: string-keyed access with no completion or checking,
`.get()` defaults papering over absent keys, and a `KeyError` surfacing three
frames away from the boundary that caused it. Convert once at the edge: a
`TypedDict` (with `Required`/`NotRequired` marking which keys the producer
guarantees) if the value stays dict-shaped, or a dataclass if it grows
behavior. Everything inward of the boundary then works with a declared,
checkable shape.

```python
from typing import NotRequired, TypedDict

class StripeChargePayload(TypedDict):
    id: str
    amount: int
    currency: str
    dispute: NotRequired[dict[str, object]]  # absent unless disputed

def parse_charge(body: bytes) -> StripeChargePayload:
    payload: StripeChargePayload = json.loads(body)
    return payload

# inward code gets key checking and completion:
def record_charge(charge: StripeChargePayload) -> None:
    ledger.credit(charge["amount"], charge["currency"])
```

**Evidence of violation:** a payload originating outside the process (HTTP
body, webhook, message-queue event, third-party API response) accessed by
string keys in **2 or more functions** in the target with no declared shape
(`TypedDict`, dataclass, `NamedTuple`, or pydantic model) anywhere on its path.
PASS: the payload is converted to (or annotated as) a declared shape at its
first touch, and inward functions take that type — cite the declaration. N/A:
the payload is proxied through without inspection, its keys are genuinely
dynamic (user-defined attributes, arbitrary metadata — cite why), or only one
function ever touches it.

Reference: [typing.TypedDict, Required and NotRequired — Python documentation](https://docs.python.org/3/library/typing.html#typing.TypedDict)
