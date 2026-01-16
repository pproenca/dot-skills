---
title: Check for Regressions After Fixing
impact: MEDIUM
impactDescription: Prevents fix from breaking existing functionality; catches unintended side effects
tags: verify, regression, testing, side-effects, validation
---

## Check for Regressions After Fixing

After fixing a bug, run the full test suite and manually verify related features. Fixes can inadvertently break other functionality that depended on the buggy behavior.

**Incorrect (only testing the fix):**

```python
# Bug: discount not applied to premium users
# Fix: Change user type check

def apply_discount(user, amount):
    # Old (buggy): if user.type == "premium"
    if user.is_premium:  # Fixed
        return amount * 0.9
    return amount

# Developer tests: premium user gets discount - PASS
# Ships fix
# Customer reports: VIP users no longer get free shipping
# VIP logic depended on user.type == "premium" being false for VIPs
```

**Correct (regression check):**

```python
# Bug: discount not applied to premium users
# Fix: Change user type check

def apply_discount(user, amount):
    if user.is_premium:  # Fixed
        return amount * 0.9
    return amount

# Verification steps:
# 1. Original bug fixed:
#    ✓ Premium user gets 10% discount

# 2. Run related tests:
#    ✓ Standard user: no discount
#    ✓ Premium user: 10% discount
#    ✗ VIP user: lost free shipping! (REGRESSION)

# 3. Investigate: VIP logic was coupled to this code
# 4. Update fix to handle VIP correctly:

def apply_discount(user, amount):
    if user.is_premium and not user.is_vip:
        return amount * 0.9
    return amount
```

**Regression check strategies:**

```bash
# Run full test suite
npm test

# Run tests related to changed files
npm test -- --findRelatedTests src/discount.js

# Run smoke tests on core flows
npm run test:smoke

# Manual verification of related features
# - List all features that touch modified code
# - Test each one manually
```

**What to check for regressions:**
- Features that call the fixed code
- Features that share data with the fixed code
- Features that run before/after the fixed code
- Edge cases that might depend on the old behavior

**When NOT to use this pattern:**
- Trivial fixes with no dependencies (typos, comments)
- New code with no existing dependents

Reference: [Software Testing Help - Regression Testing](https://www.softwaretestinghelp.com/regression-testing-tools-and-methods/)
