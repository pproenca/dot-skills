---
title: Always Use Parentheses Around Arrow Function Parameters
impact: LOW-MEDIUM
impactDescription: prevents errors when adding parameters
tags: func, arrow-functions, parentheses, syntax
---

## Always Use Parentheses Around Arrow Function Parameters

Always wrap arrow function parameters in parentheses, even for single parameters. This prevents errors when adding parameters later and maintains consistency.

**Incorrect (omitted parentheses):**

```javascript
const processOrder = order => {
  // Adding a second parameter requires restructuring
  return { ...order, processed: true };
};

const formatName = name => `Hello, ${name}!`;

const items = orders.map(order => order.items);

// Error-prone when adding parameters
const handleClick = e => e.preventDefault();  // Adding second param breaks this
```

**Correct (always use parentheses):**

```javascript
const processOrder = (order) => {
  return { ...order, processed: true };
};

const formatName = (name) => `Hello, ${name}!`;

const items = orders.map((order) => order.items);

const handleClick = (event) => event.preventDefault();
```

**Adding parameters is now trivial:**

```javascript
// Before: (order) => { ... }
// After:  (order, options) => { ... }
const processOrder = (order, options = {}) => {
  return { ...order, processed: true, ...options };
};
```

**Exception:** Omitting parentheses is allowed but not recommended:
```javascript
// Allowed but discouraged
const double = x => x * 2;
```

Reference: [Google JavaScript Style Guide - Arrow functions](https://google.github.io/styleguide/jsguide.html#features-functions-arrow-functions)
