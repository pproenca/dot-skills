---
title: Understand Why the Fix Works
impact: MEDIUM
impactDescription: Prevents cargo cult fixes; ensures fix is correct, not accidental
tags: verify, understanding, root-cause, confidence, validation
---

## Understand Why the Fix Works

Don't just verify that a fix makes the bug disappear—understand WHY it works. Fixes that work by accident may fail in other conditions or mask deeper issues.

**Incorrect (cargo cult fix):**

```python
# Bug: API returns 500 error intermittently

# Developer tries random things:
response = requests.get(url)
time.sleep(0.1)  # Added this, seems to fix it?
data = response.json()

# "I don't know why, but adding a sleep fixed it"
# Commits the fix
# Bug returns under higher load
# The sleep was just masking a race condition
```

**Correct (understand the fix):**

```python
# Bug: API returns 500 error intermittently

# Investigation:
# - 500 errors correlate with high request rates
# - Server logs show "connection pool exhausted"
# - Connections not being released properly

# Root cause: Missing connection cleanup in error path
response = requests.get(url)
try:
    data = response.json()
except Exception as e:
    response.close()  # Was missing - connections leaked on error!
    raise

# Understanding:
# 1. WHY it failed: Connections leaked when JSON parsing failed
# 2. WHY fix works: Explicit close releases connection back to pool
# 3. WHY sleep "worked": Gave leaked connections time to timeout
# 4. WHY sleep wasn't real fix: High load would still exhaust pool

# Verified understanding:
# - Can explain to colleague why this fixes it
# - Can predict when old behavior would recur
# - Can identify other code paths with same issue
```

**Questions to confirm understanding:**
1. Can you explain the bug's root cause?
2. Can you explain why your fix addresses that cause?
3. Can you predict what would happen without the fix?
4. Could there be other code paths with the same issue?
5. Would a simpler fix work? A more thorough one?

**Red flags of accidental fixes:**
- "I don't know why, but it works now"
- Fix involves adding delays/retries without understanding why
- Fix is much more complex than the problem
- Similar bugs keep appearing elsewhere

**When NOT to use this pattern:**
- Time-critical production issues (understand later)
- Third-party library bugs (can't always understand internals)

Reference: [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)
