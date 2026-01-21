---
title: Use Conditional Breakpoints
impact: MEDIUM-HIGH
impactDescription: 100× faster than hitting breakpoint manually in loops; targets exact conditions
tags: tool, breakpoints, conditional, debugger, filtering
---

## Use Conditional Breakpoints

Set breakpoints that only trigger when specific conditions are met. This lets you break on the exact iteration or data condition that causes the bug, without manually stepping through irrelevant cases.

**Incorrect (regular breakpoint in loop):**

```python
# Bug: One user out of 10,000 has incorrect balance

def calculate_balances(users):
    for user in users:
        balance = compute_balance(user)  # Breakpoint here
        user.balance = balance

# Hit F5/Continue 5,000+ times to find problematic user
# Or accidentally step past it and have to restart
```

**Correct (conditional breakpoint):**

```python
# Bug: One user out of 10,000 has incorrect balance

def calculate_balances(users):
    for user in users:
        balance = compute_balance(user)
        # Conditional breakpoint: user.id == "user_5432"
        # Or: balance < 0
        # Or: user.name == "John Doe"
        user.balance = balance

# Breakpoint only triggers for the specific problematic user
# Goes directly to the bug in 1 step
```

**Setting conditional breakpoints by IDE:**

```text
VS Code:
1. Right-click breakpoint → "Edit Breakpoint"
2. Enter expression: user.id === "user_5432"

PyCharm/IntelliJ:
1. Right-click breakpoint → "Edit Breakpoint"
2. Check "Condition" and enter: user.id == "user_5432"

Chrome DevTools:
1. Right-click line number → "Add conditional breakpoint"
2. Enter: user.id === "user_5432"
```

**Useful condition patterns:**

```javascript
// Stop on specific value
user.id === "user_5432"

// Stop on error conditions
balance < 0 || isNaN(balance)

// Stop on iteration count
i > 100 && i < 110  // Check iterations 101-109

// Stop on state change
previousValue !== currentValue

// Stop on null/undefined
data === null || data === undefined

// Stop on array conditions
items.length > 1000
```

**When NOT to use this pattern:**
- Condition evaluation is expensive (slows execution)
- You don't know the exact condition to target yet

Reference: [VS Code Debugging](https://code.visualstudio.com/docs/debugtest/debugging#_conditional-breakpoints)
