---
title: Use Observer to Broadcast State Changes to Many Subscribers
impact: CRITICAL
impactDescription: enables one-to-many notification of state changes without the publisher knowing its subscribers — the foundation of event systems, reactive UI, pub/sub, and dataflow
tags: behavioral, observer, callbacks, pub-sub, event-notification
---

## Use Observer to Broadcast State Changes to Many Subscribers

**Pattern intent:** define a one-to-many dependency so that when one object changes state, all its dependents are notified automatically. In Python a subscriber is usually just a **callback callable**; the subject keeps a list of them and invokes each on change, often from a `property` setter.

### Shapes to recognize

- Many objects must react when one object changes — UI bindings, live dashboards, dataflow
- Polling: code repeatedly checks "did it change yet?" instead of being told
- A publisher hard-coding calls to each concrete consumer it must update
- "When this value changes, notify everyone who cares — and I shouldn't know who they are"

### Problem

A price feed must update a chart, trigger alerts, and append to a log whenever the price changes. If the feed calls each consumer by name, it's coupled to all of them and can't gain a new consumer without an edit.

### Solution

Let the subject keep a list of subscriber callbacks and expose `subscribe`. On change — naturally inside a `property` setter — it calls every subscriber. The subject knows nothing about what subscribers do; subscribers register and unregister freely.

**Incorrect (publisher hard-codes each concrete consumer):**

```python
class PriceFeed:
    def __init__(self, chart, alerts, log):
        self.chart, self.alerts, self.log = chart, alerts, log
    def set_price(self, value):
        self.chart.redraw(value)         # adding a consumer means editing this method
        self.alerts.check(value)
        self.log.append(value)
```

**Correct (subject notifies a list of subscriber callbacks):**

```python
from typing import Callable

Subscriber = Callable[[float], None]

class PriceFeed:                         # the subject / publisher
    def __init__(self) -> None:
        self._subscribers: list[Subscriber] = []
        self._price = 0.0

    def subscribe(self, fn: Subscriber) -> Callable[[], None]:
        self._subscribers.append(fn)
        return lambda: self._subscribers.remove(fn)   # returns an unsubscribe handle

    @property
    def price(self) -> float:
        return self._price

    @price.setter
    def price(self, value: float) -> None:
        self._price = value
        for fn in self._subscribers:     # notify everyone, knowing nothing about them
            fn(value)

feed = PriceFeed()
feed.subscribe(lambda p: print(f"chart: {p}"))
feed.subscribe(lambda p: print("alert!" if p > 100 else "ok"))
feed.price = 105
```

**Output:**

```text
chart: 105
alert!
```

### When to use

- A change in one object must propagate to an open-ended set of others
- The publisher should not depend on the concrete types of its subscribers
- You are building events, reactive bindings, pub/sub, or dataflow

### When NOT to use

- There is exactly one fixed dependent — a direct call is simpler
- Notification order or cascading updates must be tightly controlled — observers fire in registration order
- A mature event library (signals, an event bus) already fits — don't reinvent it

### Implementation Steps

1. Give the subject a list of subscriber callables and a `subscribe` method
2. Return an unsubscribe handle from `subscribe` so listeners can detach
3. Trigger notification where state changes — a `property` setter is the natural seam
4. Iterate subscribers and call each with the new value/event
5. Keep subscribers ignorant of each other and the subject ignorant of subscriber types

### Pros

- Open/Closed: add subscribers without changing the publisher
- Loose coupling between publisher and subscribers
- Foundational for events, reactive UI, and dataflow

### Cons

- Subscribers are notified in an unspecified order
- Forgotten unsubscriptions cause memory leaks (consider `weakref` callbacks)
- Cascading notifications can be hard to trace and debug

### Related Patterns

- **Mediator** — centralizes many-to-many talk; Observer is one publisher to many subscribers
- **Command** — observed events often dispatch commands
- **Chain of Responsibility** — both relay events; CoR may stop, Observer notifies all
- **Singleton** — a global event bus subject is frequently a singleton

Reference: [refactoring.guru/design-patterns/observer/python](https://refactoring.guru/design-patterns/observer/python/example)
