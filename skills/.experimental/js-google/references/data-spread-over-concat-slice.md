---
title: Use Spread Over concat and slice
impact: LOW-MEDIUM
impactDescription: reduces array operation boilerplate by 50%
tags: data, arrays, spread, concat, slice
---

## Use Spread Over concat and slice

Use spread syntax for copying and concatenating arrays instead of `Array.prototype.slice.call()` or `concat()`. Spread is cleaner and works with any iterable.

**Incorrect (concat and slice methods):**

```javascript
function mergeOrders(pendingOrders, completedOrders) {
  return pendingOrders.concat(completedOrders);
}

function copyArray(original) {
  return original.slice();
}

function toArray(arrayLike) {
  return Array.prototype.slice.call(arrayLike);
}

function prependItem(item, items) {
  return [item].concat(items);
}
```

**Correct (spread syntax):**

```javascript
function mergeOrders(pendingOrders, completedOrders) {
  return [...pendingOrders, ...completedOrders];
}

function copyArray(original) {
  return [...original];
}

function toArray(arrayLike) {
  return [...arrayLike];
}

function prependItem(item, items) {
  return [item, ...items];
}
```

**More examples:**

```javascript
// Insert item at position
const insertAt = (array, index, item) => [
  ...array.slice(0, index),
  item,
  ...array.slice(index),
];

// Remove item at position
const removeAt = (array, index) => [
  ...array.slice(0, index),
  ...array.slice(index + 1),
];

// Clone with modifications
const updatedConfig = {
  ...config,
  timeout: 10000,
};
```

Reference: [Google JavaScript Style Guide - Spread operator](https://google.github.io/styleguide/jsguide.html#features-arrays-spread-operator)
