---
title: Include Edge Cases in Acceptance Criteria
impact: HIGH
impactDescription: prevents production bugs from untested scenarios
tags: accept, edge-cases, boundary, testing
---

## Include Edge Cases in Acceptance Criteria

Explicitly document edge cases and boundary conditions in acceptance criteria. Edge cases not in the spec are often not tested, leading to production bugs when users encounter unusual scenarios.

**Incorrect (only happy path):**

```markdown
## Feature: Shopping Cart

### Acceptance Criteria
- User can add items to cart
- User can update quantity
- User can remove items
- User can proceed to checkout
```

**Correct (including edge cases):**

```markdown
## Feature: Shopping Cart

### Happy Path
- User can add items to cart
- User can update item quantity (1-99)
- User can remove items from cart
- User can proceed to checkout with items in cart

### Edge Cases - Empty States
- [ ] Empty cart shows "Your cart is empty" message
- [ ] Empty cart shows "Continue shopping" link
- [ ] Checkout button is disabled when cart is empty

### Edge Cases - Quantity Boundaries
- [ ] Quantity cannot be set below 1 (minimum)
- [ ] Quantity cannot exceed 99 (maximum)
- [ ] Quantity cannot exceed available stock
- [ ] Non-numeric input is rejected (letters, symbols)
- [ ] Decimal quantities are rounded down

### Edge Cases - Inventory Changes
- [ ] Item removed from store while in cart shows warning
- [ ] Price change while in cart shows notification
- [ ] Stock reduction below cart quantity prompts adjustment
- [ ] Out-of-stock item cannot proceed to checkout

### Edge Cases - Concurrent Sessions
- [ ] Cart syncs across browser tabs
- [ ] Cart persists across login/logout
- [ ] Abandoned cart is preserved for 30 days

### Edge Cases - Error Conditions
- [ ] Network failure during add shows retry option
- [ ] Session expiry prompts re-login with cart preserved
- [ ] Invalid coupon code shows specific error message
```

**Common edge case categories:**
- Empty states (no data)
- Boundary values (min, max, zero)
- Invalid input (wrong type, format)
- Concurrent access (race conditions)
- Error conditions (network, timeout)
- State transitions (in-progress, cancelled)

Reference: [Atlassian - Acceptance Criteria](https://www.atlassian.com/work-management/project-management/acceptance-criteria)
