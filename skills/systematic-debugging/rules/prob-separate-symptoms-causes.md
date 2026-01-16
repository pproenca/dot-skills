---
title: Separate Symptoms from Causes
impact: CRITICAL
impactDescription: Prevents fixing symptoms while root cause continues creating new bugs
tags: prob, symptoms, root-cause, analysis
---

## Separate Symptoms from Causes

Clearly distinguish between what you observe (symptoms) and why it happens (causes). Fixing symptoms without addressing causes leads to whack-a-mole debugging where bugs keep reappearing in different forms.

**Incorrect (treating symptom as cause):**

```python
# Symptom observed: NullPointerException on line 42

def process_user(user_id):
    user = get_user(user_id)
    # Fix: Add null check (treating symptom)
    if user is None:
        return None  # "Fixed" the crash
    return user.calculate_score()

# Problem: WHY was user None?
# - Invalid user_id passed?
# - Database connection failed?
# - Race condition in user creation?
# - Cache returned stale/deleted user?
# The null check hides the real problem
```

**Correct (investigate cause before fixing):**

```python
# Symptom observed: NullPointerException on line 42

def process_user(user_id):
    user = get_user(user_id)
    # Investigation: WHY is user None?
    if user is None:
        # Diagnostic logging to find root cause
        logger.error(f"User not found: {user_id}")
        logger.error(f"Called from: {traceback.format_stack()}")
        logger.error(f"DB connection status: {db.is_connected()}")
        logger.error(f"Cache status: {cache.get_stats()}")
        raise ValueError(f"User {user_id} not found - see logs for context")
    return user.calculate_score()

# Investigation revealed: user_id came from stale session data
# Real fix: Invalidate session when user is deleted
# Symptom (null user) and cause (stale session) are different
```

**Questions to separate symptoms from causes:**
- What did I observe? (Symptom)
- What could cause this observation? (Hypothesis)
- Is fixing this observation enough, or will the problem manifest elsewhere?
- If I prevent this symptom, does the underlying issue still exist?

**When NOT to use this pattern:**
- Simple bugs where symptom location IS the cause location
- Time-critical production fixes (but schedule root cause investigation)

Reference: [Root Cause Analysis Guide](https://www.techtarget.com/searchsoftwarequality/tip/How-to-handle-root-cause-analysis-of-software-defects)
