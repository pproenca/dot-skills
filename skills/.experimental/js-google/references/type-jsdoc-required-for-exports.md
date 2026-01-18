---
title: Require JSDoc for All Exported Functions
impact: HIGH
impactDescription: enables IDE support and compiler type checking
tags: type, jsdoc, documentation, exports
---

## Require JSDoc for All Exported Functions

All exported functions must have JSDoc with `@param` and `@return` type annotations. This enables IDE autocompletion, Closure Compiler type checking, and generates documentation.

**Incorrect (missing type annotations):**

```javascript
export function calculateShippingCost(items, destination) {
  const weight = items.reduce((sum, item) => sum + item.weight, 0);
  const rate = getShippingRate(destination);
  return weight * rate;
}

export function formatOrderSummary(order) {
  return `Order #${order.id}: ${order.items.length} items, $${order.total}`;
}
```

**Correct (complete JSDoc annotations):**

```javascript
/**
 * Calculates shipping cost based on item weights and destination.
 * @param {!Array<{weight: number, sku: string}>} items The items to ship.
 * @param {string} destination The destination postal code.
 * @return {number} The calculated shipping cost in dollars.
 */
export function calculateShippingCost(items, destination) {
  const weight = items.reduce((sum, item) => sum + item.weight, 0);
  const rate = getShippingRate(destination);
  return weight * rate;
}

/**
 * Formats an order into a human-readable summary string.
 * @param {{id: number, items: !Array, total: number}} order The order to format.
 * @return {string} The formatted order summary.
 */
export function formatOrderSummary(order) {
  return `Order #${order.id}: ${order.items.length} items, $${order.total}`;
}
```

**Note:** Private functions may omit JSDoc if the signature is self-explanatory.

Reference: [Google JavaScript Style Guide - JSDoc](https://google.github.io/styleguide/jsguide.html#jsdoc)
