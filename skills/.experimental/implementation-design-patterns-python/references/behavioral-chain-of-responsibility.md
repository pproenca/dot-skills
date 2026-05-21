---
title: Use Chain of Responsibility to Pass Requests Through Handlers
impact: MEDIUM-HIGH
impactDescription: replaces hardcoded validation/auth/parsing cascades with a composable list of handlers, enables reordering or inserting handlers without editing the others, eliminates deeply nested if/else that obscures pipeline intent
tags: behavioral, chain-of-responsibility, handler-pipeline, callables, middleware
---

## Use Chain of Responsibility to Pass Requests Through Handlers

**Pattern intent:** pass a request along a sequence of handlers; each either handles it (and may stop the chain) or passes it on. In Python the chain is most naturally a **list of callables** iterated in order — no linked-list plumbing needed unless handlers carry state.

### Shapes to recognize

- A pipeline of checks: authenticate → rate-limit → validate → authorize, applied in order
- A deeply nested `if/elif` cascade where each branch guards the next step
- Middleware-style processing where steps should be reorderable or pluggable
- "I want to add a new check without touching the existing ones, and control its position"

### Problem

An API request must pass authentication, payload validation, and an authorization limit before processing. Hardcoding these as nested `if` blocks fixes their order, forces every check to know the next, and makes inserting or reordering a step a risky edit.

### Solution

Represent each step as a handler that returns `None` to pass the request along or a result to stop the chain. Drive the request through an ordered list of handlers; the first to return a non-`None` result short-circuits.

**Incorrect (nested cascade hardcodes order and coupling):**

```python
def handle(req):
    if req.user != "admin":
        return "401 unauthenticated"
    else:
        if "amount" not in req.payload:
            return "400 missing amount"
        else:
            if req.payload["amount"] > 1000:    # adding a step means nesting deeper
                return "403 over limit"
            return "200 ok"
```

**Correct (ordered list of handlers; first non-None stops the chain):**

```python
from dataclasses import dataclass
from typing import Callable

@dataclass
class Request:
    user: str
    payload: dict

# A handler returns None to pass the request on, or a string to stop the chain.
Handler = Callable[[Request], str | None]

def authenticate(req: Request) -> str | None:
    return None if req.user == "admin" else "401 unauthenticated"

def check_payload(req: Request) -> str | None:
    return None if "amount" in req.payload else "400 missing amount"

def authorize(req: Request) -> str | None:
    return "403 over limit" if req.payload["amount"] > 1000 else None

def handle(req: Request, chain: list[Handler]) -> str:
    for link in chain:
        result = link(req)
        if result is not None:           # a handler took responsibility
            return result
    return "200 ok"

chain = [authenticate, check_payload, authorize]   # reorder/insert freely
print(handle(Request("admin", {"amount": 500}), chain))
print(handle(Request("guest", {"amount": 500}), chain))
```

**Output:**

```text
200 ok
401 unauthenticated
```

### When to use

- More than one object may handle a request and the handler isn't known up front
- You want to process a request through a configurable, reorderable sequence of steps
- The set of handlers and their order should change at runtime

### When NOT to use

- Exactly one handler always applies — call it directly
- All steps must always run regardless — a plain sequence of function calls is clearer than a chain
- The order is fixed and short — nesting two checks is fine without the abstraction

### Implementation Steps

1. Define the request object the handlers operate on
2. Adopt a handler contract: return `None` to continue, or a result to stop
3. Write each step as a small handler function
4. Drive the request through an ordered list, stopping on the first non-`None` result
5. For stateful handlers, use linked objects with a `set_next` method instead of a flat list

### Pros

- Decouples senders from receivers; handlers don't know each other
- Reorder, insert, or remove steps by editing the list (Open/Closed)
- Each handler has a single responsibility and is independently testable

### Cons

- A request may fall through unhandled if no handler claims it
- Debugging is harder when it's unclear which handler acted
- Long chains can hurt performance and obscure control flow

### Related Patterns

- **Decorator** — also a chain of wrappers, but every wrapper runs; CoR may stop early
- **Command** — handlers can be Command objects; CoR routes, Command reifies the request
- **Composite** — a CoR often runs over a Composite tree (event bubbling)
- **Mediator** — centralizes communication in a hub; CoR threads it through a sequence

Reference: [refactoring.guru/design-patterns/chain-of-responsibility/python](https://refactoring.guru/design-patterns/chain-of-responsibility/python/example)
