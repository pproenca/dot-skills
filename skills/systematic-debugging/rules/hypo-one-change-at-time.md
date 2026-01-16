---
title: Test One Hypothesis at a Time
impact: CRITICAL
impactDescription: Prevents confounding variables; ensures you know which change fixed the bug
tags: hypo, isolation, variables, controlled-experiment, methodology
---

## Test One Hypothesis at a Time

Change only one variable per experiment. Making multiple changes simultaneously prevents you from knowing which change had which effect, leading to false conclusions and unfixed bugs.

**Incorrect (multiple simultaneous changes):**

```python
# Bug: API returns 500 error intermittently

# Developer makes several "fixes" at once:
def get_user(user_id):
    try:
        # Change 1: Add timeout
        response = requests.get(url, timeout=30)
        # Change 2: Add retry logic
        if response.status_code != 200:
            response = requests.get(url, timeout=30)
        # Change 3: Add null check
        data = response.json()
        if data is None:
            return default_user
        # Change 4: Add caching
        cache.set(user_id, data)
        return data
    except Exception as e:
        # Change 5: Better error handling
        logger.error(f"Failed: {e}")
        return default_user

# Bug seems fixed... but WHICH change fixed it?
# What if changes 1, 2, 4, 5 are unnecessary overhead?
# What if change 3 is hiding a different bug?
```

**Correct (test one change at a time):**

```python
# Bug: API returns 500 error intermittently

# Original code (reproduce the bug first):
def get_user(user_id):
    response = requests.get(url)
    return response.json()

# Hypothesis 1: Request timeout causes 500
# Test: Add ONLY timeout, test multiple times
def get_user_v1(user_id):
    response = requests.get(url, timeout=30)  # Only change
    return response.json()
# Result: Still fails. Timeout is not the cause.

# Hypothesis 2: Server overloaded, needs retry
# Test: Add ONLY retry (revert timeout)
def get_user_v2(user_id):
    response = requests.get(url)
    if response.status_code == 500:
        time.sleep(1)
        response = requests.get(url)  # Only change
    return response.json()
# Result: Works! Retry after brief delay fixes it.

# Now you KNOW: Server needs brief cooldown between requests
# Can investigate WHY and fix properly, or add targeted retry
```

**Controlled experiment checklist:**
- Revert to known-broken state before each test
- Change exactly one thing
- Test thoroughly (multiple runs if intermittent)
- Document result before moving to next hypothesis
- Keep working changes, revert ineffective ones

**When NOT to use this pattern:**
- Emergency production fixes (fix first, understand later)
- When changes are clearly interdependent

Reference: [A Systematic Approach to Debugging](https://ntietz.com/blog/how-i-debug-2023/)
