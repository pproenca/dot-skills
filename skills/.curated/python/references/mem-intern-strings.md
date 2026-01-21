---
title: Intern Repeated Strings to Save Memory
impact: HIGH
impactDescription: reduces duplicate string storage
tags: mem, intern, strings, deduplication
---

## Intern Repeated Strings to Save Memory

When the same string appears thousands of times (e.g., status codes, keys), each occurrence normally creates a new object. String interning reuses the same object.

**Incorrect (duplicate string objects):**

```python
def process_events(events: list[dict]) -> list[dict]:
    results = []
    for event in events:
        results.append({
            "type": event["type"],  # "click" repeated 1M times = 1M objects
            "status": event["status"],  # "success" repeated = more objects
            "timestamp": event["ts"],
        })
    return results
```

**Correct (interned strings):**

```python
import sys

def process_events(events: list[dict]) -> list[dict]:
    results = []
    for event in events:
        results.append({
            "type": sys.intern(event["type"]),  # Reuses single "click" object
            "status": sys.intern(event["status"]),  # Reuses single "success"
            "timestamp": event["ts"],
        })
    return results
```

**Alternative (pre-intern known values):**

```python
STATUS_SUCCESS = sys.intern("success")
STATUS_FAILURE = sys.intern("failure")
TYPE_CLICK = sys.intern("click")
TYPE_VIEW = sys.intern("view")

def create_event(event_type: str, status: str) -> dict:
    return {"type": event_type, "status": status}
```

**Note:** Python automatically interns string literals and identifiers. Use `sys.intern()` for runtime-generated strings with high repetition.

Reference: [sys.intern documentation](https://docs.python.org/3/library/sys.html#sys.intern)
