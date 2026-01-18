---
title: Use Explicit Nullability Modifiers
impact: HIGH
impactDescription: prevents null reference errors
tags: type, jsdoc, nullability, null, undefined
---

## Use Explicit Nullability Modifiers

Always specify nullability for reference types using `!` (non-null) or `?` (nullable). Ambiguous nullability causes runtime null reference errors.

**Incorrect (ambiguous nullability):**

```javascript
/**
 * @param {User} user - Is this nullable or not?
 * @param {Array<Order>} orders - Can this be null?
 * @return {Object} - What about the return type?
 */
export function processUserOrders(user, orders) {
  // Caller doesn't know if null checks are needed
  return {
    userId: user.id,
    orderCount: orders.length,
  };
}
```

**Correct (explicit nullability):**

```javascript
/**
 * Processes orders for a user. User must exist, orders may be empty.
 * @param {!User} user The user (required, non-null).
 * @param {!Array<!Order>} orders The orders (required array, non-null items).
 * @return {!{userId: number, orderCount: number}} The processed result.
 */
export function processUserOrders(user, orders) {
  return {
    userId: user.id,
    orderCount: orders.length,
  };
}

/**
 * Finds a user by email, returning null if not found.
 * @param {string} email The email to search for.
 * @return {?User} The user or null if not found.
 */
export function findUserByEmail(email) {
  return userDatabase.find(user => user.email === email) || null;
}
```

**Rules:**
- Primitives (`string`, `number`, `boolean`) are non-nullable by default
- Reference types (`Object`, `Array`, custom types) must use `!` or `?`
- `?` means the value can be `null` or `undefined`

Reference: [Google JavaScript Style Guide - Nullability](https://google.github.io/styleguide/jsguide.html#jsdoc-nullability)
