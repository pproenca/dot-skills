---
title: Decay Event Weights over Time
impact: HIGH
impactDescription: prevents stale preferences dominating
tags: loop, decay, recency
---

## Decay Event Weights over Time

A booking from eighteen months ago is weak evidence that a seeker still wants the same thing today — life circumstances change, preferences shift, the market moves. Without time decay, old events pile up and dominate the training signal, so the model anchors on long-gone preferences. Decaying weight with event age (exponential or bucketed) focuses the model on what the seeker currently wants while still using old events for structural patterns.

**Incorrect (full training window with uniform event weight):**

```python
def build_training_interactions(events: Iterable[Event]) -> list[dict]:
    return [
        {
            "USER_ID": e.user_id,
            "ITEM_ID": e.item_id,
            "TIMESTAMP": int(e.timestamp.timestamp()),
            "EVENT_TYPE": e.event_type,
            "EVENT_VALUE": 1.0,
        }
        for e in events
    ]
```

**Correct (exponential time decay applied via EVENT_VALUE):**

```python
def build_training_interactions(events: Iterable[Event], now: datetime) -> list[dict]:
    half_life_days = 90
    return [
        {
            "USER_ID": e.user_id,
            "ITEM_ID": e.item_id,
            "TIMESTAMP": int(e.timestamp.timestamp()),
            "EVENT_TYPE": e.event_type,
            "EVENT_VALUE": float(0.5 ** ((now - e.timestamp).days / half_life_days)),
        }
        for e in events
    ]
```

Reference: [Google — Rules of Machine Learning, Rule 32: Re-use Code Between Training and Serving Pipelines](https://developers.google.com/machine-learning/guides/rules-of-ml)
