---
title: Use typedef for Complex Object Types
impact: MEDIUM-HIGH
impactDescription: enables reusable type definitions across files
tags: type, jsdoc, typedef, documentation
---

## Use typedef for Complex Object Types

Define reusable type definitions with `@typedef` for complex object shapes. Inline object types become unreadable and cannot be reused.

**Incorrect (inline complex types):**

```javascript
/**
 * @param {{id: number, email: string, profile: {name: string, avatar: ?string, preferences: {theme: string, notifications: boolean}}}} user
 * @param {{items: !Array<{sku: string, quantity: number, price: number}>, shipping: {address: string, method: string}, payment: {method: string, last4: string}}} order
 * @return {{success: boolean, orderId: string, estimatedDelivery: !Date}}
 */
export function processCheckout(user, order) {
  // Impossible to read the types
}
```

**Correct (typedef for reusable types):**

```javascript
/**
 * @typedef {{
 *   name: string,
 *   avatar: ?string,
 *   preferences: !UserPreferences,
 * }}
 */
let UserProfile;

/**
 * @typedef {{theme: string, notifications: boolean}}
 */
let UserPreferences;

/**
 * @typedef {{
 *   id: number,
 *   email: string,
 *   profile: !UserProfile,
 * }}
 */
let User;

/**
 * @typedef {{
 *   success: boolean,
 *   orderId: string,
 *   estimatedDelivery: !Date,
 * }}
 */
let CheckoutResult;

/**
 * Processes a checkout for the given user and order.
 * @param {!User} user The authenticated user.
 * @param {!Order} order The order to process.
 * @return {!CheckoutResult} The checkout result.
 */
export function processCheckout(user, order) {
  // Clear, readable parameter types
}
```

**Benefits:**
- Types can be imported and reused across files
- IDE provides better autocompletion
- Documentation is more maintainable

Reference: [Google JavaScript Style Guide - Typedef](https://google.github.io/styleguide/jsguide.html#jsdoc-typedef-annotations)
