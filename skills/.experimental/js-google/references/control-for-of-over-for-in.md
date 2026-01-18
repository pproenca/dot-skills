---
title: Prefer for-of Over for-in for Iteration
impact: MEDIUM
impactDescription: prevents prototype property bugs
tags: control, loops, for-of, for-in, iteration
---

## Prefer for-of Over for-in for Iteration

Use `for-of` to iterate arrays and iterables. Reserve `for-in` only for dict-style objects, and always check `hasOwnProperty`. Never use `for-in` on arrays.

**Incorrect (for-in on arrays, missing hasOwnProperty):**

```javascript
const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];

// Iterates indices as strings, includes prototype properties
for (const index in orders) {
  console.log(orders[index].id);
}

const config = { timeout: 5000, retries: 3 };

// May include inherited properties
for (const key in config) {
  console.log(`${key}: ${config[key]}`);
}
```

**Correct (for-of for arrays, guarded for-in for objects):**

```javascript
const orders = [{ id: 1 }, { id: 2 }, { id: 3 }];

// for-of iterates values directly
for (const order of orders) {
  console.log(order.id);
}

const config = { timeout: 5000, retries: 3 };

// for-in with hasOwnProperty check
for (const key in config) {
  if (Object.prototype.hasOwnProperty.call(config, key)) {
    console.log(`${key}: ${config[key]}`);
  }
}
```

**Alternative (Object.entries for key-value pairs):**

```javascript
const config = { timeout: 5000, retries: 3 };

// Modern approach - no hasOwnProperty needed
for (const [key, value] of Object.entries(config)) {
  console.log(`${key}: ${value}`);
}

// Or with Object.keys
for (const key of Object.keys(config)) {
  console.log(`${key}: ${config[key]}`);
}
```

Reference: [Google JavaScript Style Guide - for-in loop](https://google.github.io/styleguide/jsguide.html#features-for-in-loop)
