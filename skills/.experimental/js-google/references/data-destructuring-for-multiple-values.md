---
title: Use Destructuring for Multiple Property Access
impact: MEDIUM
impactDescription: reduces repetition and improves clarity
tags: data, destructuring, objects, arrays
---

## Use Destructuring for Multiple Property Access

Use destructuring to extract multiple properties from objects or arrays. This reduces repetition and makes data dependencies explicit.

**Incorrect (repeated property access):**

```javascript
function processOrder(order) {
  const orderId = order.id;
  const items = order.items;
  const shipping = order.shipping;
  const total = order.total;

  console.log(`Processing order ${orderId}`);
  return {
    orderId,
    itemCount: items.length,
    shippingMethod: shipping.method,
    grandTotal: total,
  };
}

function getCoordinates(point) {
  return `(${point.x}, ${point.y})`;
}
```

**Correct (destructuring):**

```javascript
function processOrder(order) {
  const { id: orderId, items, shipping, total } = order;

  console.log(`Processing order ${orderId}`);
  return {
    orderId,
    itemCount: items.length,
    shippingMethod: shipping.method,
    grandTotal: total,
  };
}

function getCoordinates({ x, y }) {
  return `(${x}, ${y})`;
}
```

**Array destructuring:**

```javascript
// Extracting specific positions
const [first, second, ...rest] = items;

// Swapping values
[a, b] = [b, a];

// Skipping elements
const [, , third] = ['a', 'b', 'c'];
```

**With defaults:**

```javascript
function createUser({ name, role = 'viewer', isActive = true } = {}) {
  return { name, role, isActive };
}

createUser({ name: 'Alice' });  // { name: 'Alice', role: 'viewer', isActive: true }
createUser();  // { name: undefined, role: 'viewer', isActive: true }
```

Reference: [Google JavaScript Style Guide - Destructuring](https://google.github.io/styleguide/jsguide.html#features-objects-destructuring)
