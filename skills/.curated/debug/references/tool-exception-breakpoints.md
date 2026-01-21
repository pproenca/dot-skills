---
title: Use Exception Breakpoints
impact: MEDIUM-HIGH
impactDescription: 5× faster exception debugging; catches errors at throw point with full context
tags: tool, exceptions, breakpoints, errors, debugger
---

## Use Exception Breakpoints

Configure the debugger to break when exceptions are thrown, not just when they're caught. This stops execution at the exact moment of failure, showing the complete state before error handling obscures it.

**Incorrect (only seeing caught exception):**

```python
try:
    result = process_complex_data(data)
except Exception as e:
    logger.error(f"Processing failed: {e}")  # Only see: "KeyError: 'user'"
    return None

# Exception message gives location but not context
# What was data? What was the full state at failure?
```

**Correct (exception breakpoint at throw point):**

```python
# Enable "Break on All Exceptions" in debugger

def process_complex_data(data):
    users = data.get('users', [])
    for user in users:
        # DEBUGGER STOPS HERE on the KeyError
        # Can inspect: user = {'name': 'Alice'}, has no 'id' key
        # Can see full data, full users list, loop index
        name = user['name']
        id = user['id']  # KeyError thrown here!

# Now you see:
# - Exactly which user dict was malformed
# - Index in list where it occurred
# - Full context of surrounding data
```

**Setting exception breakpoints by IDE:**

```text
VS Code (Python):
1. Debug sidebar → Breakpoints section
2. Check "Raised Exceptions" or "Uncaught Exceptions"

VS Code (JavaScript):
1. Debug sidebar → Breakpoints section
2. Check "Caught Exceptions" and/or "Uncaught Exceptions"

Chrome DevTools:
1. Sources panel → Breakpoints sidebar
2. Check "Pause on caught exceptions"

PyCharm:
1. Run → View Breakpoints
2. Python Exception Breakpoints → Add specific exceptions
```

**Types of exception breakpoints:**

| Type | Use When |
|------|----------|
| Uncaught only | Production debugging, avoid noise |
| All exceptions | Finding swallowed errors |
| Specific exception | Known error type to investigate |
| Conditional | Exception meets certain criteria |

**When NOT to use this pattern:**
- Library throws many expected exceptions (too noisy)
- Error handling is the thing being debugged

Reference: [VS Code Exception Breakpoints](https://code.visualstudio.com/docs/debugtest/debugging#_exception-breakpoints)
