---
title: Isolate Variables Systematically
impact: CRITICAL
impactDescription: reduces search space by 50% per iteration
tags: repro, isolation, variables, divide-and-conquer
---

## Isolate Variables Systematically

When a bug depends on multiple factors, change one variable at a time to identify which conditions are necessary for reproduction. This systematic isolation narrows the search space exponentially.

**Incorrect (changing multiple variables at once):**

```python
# Bug: Payment fails for some users
# Testing approach: Random changes

def debug_payment_failure():
    # Try different user, different browser, different amount
    test_with_user("alice", browser="chrome", amount=100)
    test_with_user("bob", browser="firefox", amount=50)
    # Can't determine which variable matters
```

**Correct (isolating one variable at a time):**

```python
# Bug: Payment fails for some users
# Testing approach: Isolate each variable

def debug_payment_failure():
    # Control: Known failing case
    test_with_user("alice", browser="chrome", amount=100)  # FAILS

    # Test 1: Change only the user
    test_with_user("bob", browser="chrome", amount=100)    # PASSES
    # Conclusion: User-specific issue

    # Test 2: What's different about alice?
    # alice has special characters in address field
```

**When to use this pattern:**
- Bug occurs only under specific conditions
- Multiple environmental factors could be involved
- Intermittent bugs with unclear triggers

Reference: [MIT 6.031 - Reading 13: Debugging](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)
