---
title: Master Step Over, Step Into, Step Out
impact: MEDIUM-HIGH
impactDescription: Efficient navigation through code; 5× faster than random stepping
tags: tool, debugger, stepping, navigation, execution-control
---

## Master Step Over, Step Into, Step Out

Use the right stepping command to navigate efficiently. Step Into for suspicious functions, Step Over for trusted code, Step Out when you've seen enough. Random F10/F11 pressing wastes time.

**Incorrect (random stepping):**

```python
def process(data):
    validated = validate(data)      # F11 into 50-line function
    normalized = normalize(validated)  # F11 into another function
    result = transform(normalized)     # F11 again...
    return save(result)                # Lost in library code

# Developer presses F11 repeatedly, ends up deep in library internals
# Loses context of original debugging goal
```

**Correct (deliberate navigation):**

```python
def process(data):
    validated = validate(data)      # F10 - trust validation
    normalized = normalize(validated)  # F11 - suspicious, investigate
    # ... inside normalize, find issue ...
    # Shift+F11 - step out, back to process()
    result = transform(normalized)     # F10 - trust transform
    return save(result)                # F11 - check save behavior
```

**Stepping commands reference:**

| Action | VS Code | PyCharm | Chrome | Purpose |
|--------|---------|---------|--------|---------|
| Step Over | F10 | F8 | F10 | Execute line, don't enter functions |
| Step Into | F11 | F7 | F11 | Enter function on current line |
| Step Out | Shift+F11 | Shift+F8 | Shift+F11 | Run to end of current function |
| Continue | F5 | F9 | F8 | Run to next breakpoint |
| Run to Cursor | Ctrl+F10 | Alt+F9 | -- | Run to specific line |

**When to use each:**

```python
def process_order(order):
    # Step OVER (F10): Library/utility calls you trust
    logger.info(f"Processing {order.id}")  # Trust logging
    validated = validate(order)  # Trust validation (if working)

    # Step INTO (F11): Suspicious or unfamiliar code
    total = calculate_total(order)  # Bug might be here
    discount = apply_discount(total)  # Or here

    # Step OUT (Shift+F11): When you've seen enough
    # Inside apply_discount, realize bug is elsewhere
    # Step out to return to process_order

    # Run to CURSOR: Skip to specific point
    # Set cursor at return statement, run directly there
    return finalize(order, total - discount)
```

**When NOT to use this pattern:**
- Async code (stepping can be unpredictable)
- Multi-threaded code (other threads keep running)

Reference: [Chrome DevTools Debugging](https://developer.chrome.com/docs/devtools/javascript/reference/)
