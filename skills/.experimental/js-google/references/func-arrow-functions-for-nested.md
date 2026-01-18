---
title: Prefer Arrow Functions for Nested Functions
impact: MEDIUM
impactDescription: simplifies this binding and reduces boilerplate
tags: func, arrow-functions, this, closures
---

## Prefer Arrow Functions for Nested Functions

Use arrow functions instead of `function` keyword for nested functions. Arrow functions lexically bind `this`, eliminating common `this` binding bugs.

**Incorrect (function keyword loses this context):**

```javascript
class OrderProcessor {
  constructor(orders) {
    this.orders = orders;
    this.total = 0;
  }

  calculateTotal() {
    this.orders.forEach(function(order) {
      this.total += order.amount;  // this is undefined or window!
    });
    return this.total;
  }

  processAsync() {
    const self = this;  // Workaround for this binding
    return fetch('/api/process').then(function(response) {
      return self.handleResponse(response);  // Using self hack
    });
  }
}
```

**Correct (arrow functions preserve this):**

```javascript
class OrderProcessor {
  constructor(orders) {
    this.orders = orders;
    this.total = 0;
  }

  calculateTotal() {
    this.orders.forEach((order) => {
      this.total += order.amount;  // this is correctly bound
    });
    return this.total;
  }

  processAsync() {
    return fetch('/api/process').then((response) => {
      return this.handleResponse(response);  // No self hack needed
    });
  }
}
```

**When to use function keyword:**
- Top-level exported functions
- Object methods needing dynamic `this`
- Functions requiring `arguments` object

Reference: [Google JavaScript Style Guide - Arrow functions](https://google.github.io/styleguide/jsguide.html#features-functions-arrow-functions)
