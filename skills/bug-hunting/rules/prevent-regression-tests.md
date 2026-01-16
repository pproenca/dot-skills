---
title: Add Regression Tests for Every Fix
impact: LOW
impactDescription: prevents same bug from recurring
tags: prevent, regression, testing, verification
---

## Add Regression Tests for Every Fix

Every bug fix should include a test that would have caught the bug. This regression test ensures the bug never returns and documents the expected behavior for future developers.

**Incorrect (fix without test):**

```python
# Bug: Discount calculation wrong for orders over $1000
# PR: Fix discount calculation
# No test added

def apply_discount(total):
    if total > 1000:
        return total * 0.9  # Fixed: was 0.09
    return total

# 6 months later: Someone refactors this code
# Bug reappears because no test protected it
```

**Correct (fix with regression test):**

```python
# Bug: Discount calculation wrong for orders over $1000
# PR: Fix discount calculation + add regression test

def apply_discount(total):
    if total > 1000:
        return total * 0.9
    return total

# test_discounts.py
def test_discount_for_orders_over_1000():
    """Regression test for JIRA-4521: Discount was 0.09 instead of 0.9"""
    result = apply_discount(1500)
    assert result == 1350  # 10% discount = $150 off

def test_no_discount_for_orders_under_1000():
    result = apply_discount(500)
    assert result == 500

def test_discount_at_boundary():
    result = apply_discount(1000)
    assert result == 1000  # Exactly $1000 gets no discount

    result = apply_discount(1001)
    assert result == 900.9  # Just over threshold gets discount
```

**Regression test checklist:**
- [ ] Test reproduces the original bug (fails before fix)
- [ ] Test passes after fix
- [ ] Test covers edge cases around the bug
- [ ] Test documents the expected behavior
- [ ] Reference to original bug ticket in comment

Reference: [MIT 6.031 - Reading 13: Debugging](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)
