---
title: Use Time-Travel Debugging When Available
impact: MEDIUM-HIGH
impactDescription: eliminates restart cycles during debugging
tags: debug, time-travel, replay, rr
---

## Use Time-Travel Debugging When Available

Time-travel debuggers record program execution and let you step backward as well as forward. This is invaluable for finding where state became corrupted without needing to restart and reproduce.

**Incorrect (restart to re-examine earlier state):**

```python
def process_data(data):
    transformed = transform(data)          # Passed this point
    validated = validate(transformed)      # Passed this point
    result = calculate(validated)          # Bug here: wrong result
    # Want to check 'transformed' value, but already stepped past it
    # Must restart debugging from the beginning
    return result

# Debugging session:
# 1. Run to breakpoint at calculate()
# 2. Realize need to see transform() output
# 3. Restart entire session
# 4. Set new breakpoint at transform()
# 5. Repeat for each hypothesis...
```

**Correct (time-travel debugging):**

```python
def process_data(data):
    transformed = transform(data)          # Can return here anytime
    validated = validate(transformed)      # Can return here anytime
    result = calculate(validated)          # Currently stopped here
    return result

# Time-travel debugging session (using rr, VS Code, or browser DevTools):
# 1. Run to breakpoint at calculate()
# 2. Examine 'validated' - looks wrong
# 3. Step BACKWARD to validate() exit
# 4. Examine 'transformed' - also wrong
# 5. Step BACKWARD to transform() entry
# 6. Watch 'data' transform step by step
# 7. Found: transform() mutates input incorrectly at line 45
# No restart needed!
```

**Time-travel tools:**
- **rr** (Linux): Record and replay C/C++/Rust programs
- **VS Code**: Built-in time-travel for JavaScript debugging
- **Chrome DevTools**: Performance recording with state snapshots
- **WinDbg Preview**: Time Travel Debugging for Windows

Reference: [WeAreBrain - 10 Debugging Techniques](https://wearebrain.com/blog/10-effective-debugging-techniques-for-developers/)
