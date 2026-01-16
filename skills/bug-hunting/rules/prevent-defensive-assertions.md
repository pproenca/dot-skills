---
title: Use Assertions for Invariant Checking
impact: LOW
impactDescription: reduces debugging time by catching errors early
tags: prevent, assertions, invariants, defensive-coding
---

## Use Assertions for Invariant Checking

Add assertions to verify assumptions that should always be true. Assertions catch bugs at the point where invariants are violated, rather than later when symptoms appear far from the cause.

**Incorrect (no assertion, bug discovered far from source):**

```python
def transfer_money(from_account, to_account, amount):
    from_account.balance -= amount
    to_account.balance += amount
    # No validation of inputs
    # Bug: negative amount passed, money flows wrong direction
    # Discovered: Week later in accounting audit
```

**Correct (assertions catch invalid state early):**

```python
def transfer_money(from_account, to_account, amount):
    # Preconditions: Assert inputs are valid
    assert amount > 0, f"Transfer amount must be positive, got {amount}"
    assert from_account is not to_account, "Cannot transfer to same account"
    assert from_account.balance >= amount, "Insufficient funds"

    from_account.balance -= amount
    to_account.balance += amount

    # Postcondition: Assert result is valid
    assert from_account.balance >= 0, "Balance went negative after transfer"

    # Invariant: Total money in system unchanged
    # (In production, use proper transaction validation)
```

**When to use assertions:**
- Function preconditions (valid parameters)
- Postconditions (valid return values)
- Loop invariants (state that must be true each iteration)
- Impossible states ("this should never happen")

**When NOT to use assertions:**
- User input validation (use proper error handling)
- Expected error conditions (use exceptions)
- Assertions can be disabled in production

Reference: [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
