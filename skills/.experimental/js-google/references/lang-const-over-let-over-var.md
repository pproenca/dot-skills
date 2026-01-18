---
title: Use const by Default, let When Needed, Never var
impact: CRITICAL
impactDescription: prevents reassignment bugs and enables optimization
tags: lang, variables, const, let, var
---

## Use const by Default, let When Needed, Never var

Declare variables with `const` by default. Use `let` only when reassignment is necessary. Never use `var` as it has confusing function-scoped hoisting behavior.

**Incorrect (var causes hoisting bugs):**

```javascript
function processOrders(orders) {
  for (var i = 0; i < orders.length; i++) {
    var order = orders[i];  // Hoisted to function scope
    setTimeout(() => {
      console.log(order.id);  // Always logs last order's id
    }, 100);
  }
  console.log(i);  // i is accessible here (function scoped)
}
```

**Correct (const/let with proper scoping):**

```javascript
function processOrders(orders) {
  for (let i = 0; i < orders.length; i++) {
    const order = orders[i];  // Block scoped, new binding each iteration
    setTimeout(() => {
      console.log(order.id);  // Logs correct order id
    }, 100);
  }
  // i is not accessible here (block scoped)
}
```

**Note:** Declare one variable per declaration statement. Never use `const a = 1, b = 2;`.

Reference: [Google JavaScript Style Guide - Local variable declarations](https://google.github.io/styleguide/jsguide.html#features-local-variable-declarations)
