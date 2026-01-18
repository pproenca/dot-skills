---
title: Annotate Enums with Static Literal Values
impact: MEDIUM
impactDescription: enables compiler optimization and type checking
tags: type, jsdoc, enum, constants
---

## Annotate Enums with Static Literal Values

Define enums with `@enum` annotation on object literals. Values must be static literals (not computed). Enum names use UpperCamelCase, values use CONSTANT_CASE.

**Incorrect (computed values or missing annotation):**

```javascript
// Missing @enum annotation
const OrderStatus = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  SHIPPED: 'shipped',
};

// Computed values not allowed in string enums
const BASE = 'order_';
/** @enum {string} */
const OrderType = {
  STANDARD: BASE + 'standard',  // Computed!
  EXPRESS: BASE + 'express',
};
```

**Correct (static literal enum values):**

```javascript
/**
 * Order processing status.
 * @enum {string}
 */
const OrderStatus = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  SHIPPED: 'shipped',
  DELIVERED: 'delivered',
  CANCELLED: 'cancelled',
};

/**
 * Numeric priority levels.
 * @enum {number}
 */
const Priority = {
  LOW: 1,
  MEDIUM: 2,
  HIGH: 3,
  CRITICAL: 4,
};

/**
 * Updates order status.
 * @param {string} orderId The order ID.
 * @param {!OrderStatus} status The new status.
 */
export function updateOrderStatus(orderId, status) {
  database.orders.update(orderId, { status });
}
```

**Rules:**
- String enums: values must be string literals
- Number enums: may use arithmetic expressions
- No properties added after definition

Reference: [Google JavaScript Style Guide - Enums](https://google.github.io/styleguide/jsguide.html#features-enums)
