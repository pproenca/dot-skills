---
title: Use match Statement for Structural Pattern Matching
impact: LOW
impactDescription: reduces branch complexity
tags: py, match, pattern-matching, python310
---

## Use match Statement for Structural Pattern Matching

Python 3.10+ `match` statement provides structural pattern matching that's clearer and often faster than chained if/elif for complex conditions.

**Incorrect (verbose if/elif chain):**

```python
def process_event(event: dict) -> str:
    event_type = event.get("type")
    if event_type == "click":
        if "target" in event and "position" in event:
            return f"Click on {event['target']} at {event['position']}"
        return "Invalid click event"
    elif event_type == "keypress":
        if "key" in event:
            return f"Key pressed: {event['key']}"
        return "Invalid keypress event"
    elif event_type == "scroll":
        return f"Scroll by {event.get('delta', 0)}"
    else:
        return "Unknown event"
```

**Correct (structural pattern matching):**

```python
def process_event(event: dict) -> str:
    match event:
        case {"type": "click", "target": target, "position": pos}:
            return f"Click on {target} at {pos}"
        case {"type": "click"}:
            return "Invalid click event"
        case {"type": "keypress", "key": key}:
            return f"Key pressed: {key}"
        case {"type": "keypress"}:
            return "Invalid keypress event"
        case {"type": "scroll", "delta": delta}:
            return f"Scroll by {delta}"
        case {"type": "scroll"}:
            return "Scroll by 0"
        case _:
            return "Unknown event"
```

**With guards:**

```python
match user:
    case {"role": "admin", "active": True}:
        grant_admin_access()
    case {"role": role} if role in ("editor", "moderator"):
        grant_limited_access()
    case _:
        grant_read_only()
```

Reference: [PEP 634 - Structural Pattern Matching](https://peps.python.org/pep-0634/)
