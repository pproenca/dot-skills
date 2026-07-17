---
title: Write functions instead of single-method classes
tags: alt, classes, functions, indirection
---

## Write functions instead of single-method classes

A class whose `__init__` stores arguments and whose single public method uses
them is a function call split across two statements — the class adds a name to
invent, an instantiation site, and an object lifetime, and buys nothing:
there is no state evolving between calls, no polymorphic substitution, no
second method sharing the fields. The habit ports from class-first languages
and from legacy codebases full of `*Service`/`*Manager` singletons. A
module-level function carries the same behavior; when callers need the
arguments pre-bound, `functools.partial` or a closure does the binding without
a class.

**Incorrect (a function wearing a class costume):**

```python
class DiscountCalculator:
    def __init__(self, campaign: Campaign, member_tier: Tier) -> None:
        self.campaign = campaign
        self.member_tier = member_tier

    def calculate(self, cart_total_cents: int) -> int:
        rate = self.campaign.rate_for(self.member_tier)
        return round(cart_total_cents * rate)

amount = DiscountCalculator(campaign, tier).calculate(total)
```

**Correct (the same behavior, one definition, one call):**

```python
def calculate_discount(campaign: Campaign, member_tier: Tier, cart_total_cents: int) -> int:
    rate = campaign.rate_for(member_tier)
    return round(cart_total_cents * rate)

# pre-binding, when a callable is genuinely needed:
member_discount = functools.partial(calculate_discount, campaign, tier)
```

**Evidence of violation:** a class in the target whose `__init__` only stores
constructor arguments and which exposes exactly **one public method** (dunders
and properties over stored args excluded), with no attribute mutated between
calls. PASS as a class only with cited evidence of a structural need: it
implements a `Protocol`/ABC that a call site consumes polymorphically (cite the
site), a framework instantiates it by contract (cite the registration), or a
second public method shares the state. N/A: no such class in the target.
The fix is a module-level function; name `functools.partial`/a closure when
call sites need pre-bound arguments.

Reference: [functools.partial — Python documentation](https://docs.python.org/3/library/functools.html#functools.partial)
