---
title: Use Spread Operator Instead of Function.apply
impact: MEDIUM
impactDescription: cleaner syntax, works with new operator
tags: func, spread, apply, function-calls
---

## Use Spread Operator Instead of Function.apply

Use spread syntax (`...args`) when calling functions with array arguments. Spread is cleaner than `Function.prototype.apply()` and works with `new`.

**Incorrect (apply for array arguments):**

```javascript
function processItems(processor, items) {
  // Awkward apply syntax
  return processor.apply(null, items);
}

function findMax(numbers) {
  return Math.max.apply(Math, numbers);
}

function createWithArgs(Constructor, args) {
  // apply doesn't work with new
  return new (Function.prototype.bind.apply(Constructor, [null].concat(args)))();
}
```

**Correct (spread syntax):**

```javascript
function processItems(processor, items) {
  return processor(...items);
}

function findMax(numbers) {
  return Math.max(...numbers);
}

function createWithArgs(Constructor, args) {
  return new Constructor(...args);
}
```

**Common use cases:**

```javascript
// Combining arrays
const allOrders = [...pendingOrders, ...completedOrders];

// Copying arrays
const ordersCopy = [...originalOrders];

// Converting iterables to arrays
const chars = [...'hello'];  // ['h', 'e', 'l', 'l', 'o']

// Spreading into function calls
console.log(...['Debug:', errorMessage, stackTrace]);
```

Reference: [Google JavaScript Style Guide - Spread operator](https://google.github.io/styleguide/jsguide.html#features-spread-operator)
