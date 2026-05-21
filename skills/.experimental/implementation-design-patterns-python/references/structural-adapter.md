---
title: Use Adapter to Make Incompatible Interfaces Cooperate
impact: HIGH
impactDescription: enables reusing a class whose interface doesn't match what callers expect, eliminates ad-hoc conversion code scattered across call sites, isolates the third-party API translation in one wrapper
tags: structural, adapter, duck-typing, interface-translation, wrapper
---

## Use Adapter to Make Incompatible Interfaces Cooperate

**Pattern intent:** let two objects with incompatible interfaces work together by wrapping one in an object that exposes the interface the other expects. In Python, duck typing means you only need an Adapter when the *method names or shapes* differ — when they already match, pass the object directly. The adapter is a thin wrapper class (or a function) translating one call into another.

### Shapes to recognize

- A third-party or legacy class you cannot edit whose method names differ from your code's expectations
- Conversion code (`xml_to_dict(...)`, reshaping arguments) repeated at every call site
- "I want to drop this library in behind my existing interface without rewriting callers"
- Several backends that should be interchangeable but expose different method names

### Problem

Application code calls `notifier.notify(text)`. A new requirement routes alerts to Slack, whose client exposes `post_message(channel, body)` instead. You cannot change the vendor class, and sprinkling `client.post_message("ops", text)` across the app couples every caller to Slack's shape.

### Solution

Write an adapter that implements the interface callers expect (`Notifier`) and forwards to the adaptee's actual API, translating arguments. Callers keep depending on the `Protocol`; only the adapter knows the vendor's method names.

**Incorrect (every caller translates to the vendor API by hand):**

```python
client = SlackClient()
# Each site couples to Slack's signature; swapping vendors means editing all of them.
client.post_message("ops", "disk 90% full")
client.post_message("ops", "deploy finished")
```

**Correct (one adapter exposes the expected interface):**

```python
from typing import Protocol

class Notifier(Protocol):
    def notify(self, text: str) -> None: ...

class SlackClient:                       # third-party adaptee; cannot be modified
    def post_message(self, channel: str, body: str) -> None:
        print(f"slack#{channel}: {body}")

class SlackNotifier:                     # adapter: Notifier interface → SlackClient API
    def __init__(self, client: SlackClient, channel: str) -> None:
        self._client, self._channel = client, channel

    def notify(self, text: str) -> None:
        self._client.post_message(self._channel, text)

def send_alerts(notifier: Notifier) -> None:   # depends only on the Protocol
    notifier.notify("disk 90% full")

send_alerts(SlackNotifier(SlackClient(), channel="ops"))
```

**Output:**

```text
slack#ops: disk 90% full
```

### When to use

- You want to use an existing class whose interface doesn't match what your code expects
- You need several interchangeable backends that happen to expose different method names
- You are isolating a volatile third-party API behind a stable seam

### When NOT to use

- The adaptee already has the methods your code calls — duck typing means no adapter is needed
- The translation is one trivial call — a small function or `functools.partial` is lighter than a class
- You actually need to simplify a *whole subsystem*, not match one interface — that is **Facade**

### Implementation Steps

1. Define (or identify) the `Protocol` your callers expect
2. Create an adapter class that accepts the adaptee via its constructor
3. Implement each expected method by translating arguments and delegating to the adaptee
4. Type call sites against the `Protocol`, not the concrete adapter
5. Add more adapters for additional backends as needed; callers stay unchanged

### Pros

- Single Responsibility: interface translation lives in one class, away from business logic
- Open/Closed: new backends arrive as new adapters without touching callers
- Lets incompatible or legacy classes participate behind a clean interface

### Cons

- Adds a wrapper class and one layer of indirection
- For deep interface mismatches the adapter can grow complex — sometimes changing the caller is simpler

### Related Patterns

- **Facade** — defines a new simplified interface over a subsystem; Adapter reuses an existing interface
- **Decorator** — keeps the same interface and adds behavior; Adapter changes the interface
- **Proxy** — keeps the same interface and controls access; Adapter converts it
- **Bridge** — designed up front to vary two sides; Adapter retrofits cooperation after the fact

Reference: [refactoring.guru/design-patterns/adapter/python](https://refactoring.guru/design-patterns/adapter/python/example)
