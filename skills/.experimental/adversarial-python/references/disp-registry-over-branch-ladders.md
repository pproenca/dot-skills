---
title: Route discriminator dispatch through a registry, match, or polymorphism
tags: disp, dispatch, registry, events, versioning
---

## Route discriminator dispatch through a registry, match, or polymorphism

The default failure is additive, not authored: given an endpoint that receives
several event types in several versions, the model extends the `if/elif` ladder
it found — one more branch per event per version — because the surrounding code
did it that way. The ladder couples every handler into one function, hides the
unhandled case (falls off the end, returns `None`), and turns each new variant
into an edit of shared code instead of a registration. A discriminator with
parallel-shaped branches is a routing problem: key a registry by the
discriminator, or use a `match` statement for a small closed set, or dispatch
polymorphically when the variants already are classes.

**Incorrect (each new event version edits the shared ladder):**

```python
def handle_webhook(event: WebhookEvent) -> Outcome:
    if event.name == "order.created" and event.version == 1:
        order = parse_order_v1(event.payload)
        return create_order(order)
    elif event.name == "order.created" and event.version == 2:
        order = parse_order_v2(event.payload)
        return create_order(order)
    elif event.name == "order.refunded" and event.version == 1:
        refund = parse_refund_v1(event.payload)
        return apply_refund(refund)
    # falls through silently for anything unhandled
```

**Correct (handlers register against the discriminator; the missing case is explicit):**

```python
Handler = Callable[[dict[str, object]], Outcome]

HANDLERS: dict[tuple[str, int], Handler] = {
    ("order.created", 1): handle_order_created_v1,
    ("order.created", 2): handle_order_created_v2,
    ("order.refunded", 1): handle_order_refunded_v1,
}

def handle_webhook(event: WebhookEvent) -> Outcome:
    try:
        handler = HANDLERS[(event.name, event.version)]
    except KeyError:
        raise UnsupportedEventError(event.name, event.version) from None
    return handler(event.payload)
```

**Evidence of violation:** an `if/elif` chain (or equivalent early-return
sequence) of **3 or more branches** in which every branch compares the *same*
discriminator expression (an event name, a type/kind tag, a version field, a
command string) against constants, and the branches perform parallel-shaped
work (each maps the same kind of input to the same kind of outcome). PASS: the
dispatch goes through a mapping/registry, a `match` statement over the
discriminator, single-dispatch (`functools.singledispatch`), or method
polymorphism — cite the construct. N/A: no such chain in the target, or the
branches are genuinely heterogeneous (guard clauses, validation short-circuits,
range/inequality logic that a key lookup cannot express — cite why). A chain
copied from surrounding legacy code is still a FAIL; consistency is not a
carve-out.

Reference: [functools.singledispatch — Python documentation](https://docs.python.org/3/library/functools.html#functools.singledispatch)
