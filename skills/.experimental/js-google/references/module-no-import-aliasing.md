---
title: Avoid Unnecessary Import Aliasing
impact: HIGH
impactDescription: maintains searchability and code comprehension
tags: module, imports, aliasing, naming
---

## Avoid Unnecessary Import Aliasing

Keep original export names when importing. Aliasing creates a mental mapping burden and breaks global search/replace refactoring.

**Incorrect (unnecessary aliasing obscures origin):**

```javascript
import {
  OrderStatus as Status,
  createOrder as makeOrder,
  validateOrder as checkOrder
} from './orderService.js';

export function processNewOrder(items) {
  const order = makeOrder(items);  // What is makeOrder?
  checkOrder(order);
  return order.status === Status.PENDING;
}
```

**Correct (preserves original names):**

```javascript
import {
  OrderStatus,
  createOrder,
  validateOrder
} from './orderService.js';

export function processNewOrder(items) {
  const order = createOrder(items);  // Clear origin
  validateOrder(order);
  return order.status === OrderStatus.PENDING;
}
```

**When aliasing IS appropriate:**
- Name collisions between imports from different modules
- Adapting third-party API names to codebase conventions

```javascript
// Collision requires aliasing
import { Button as MuiButton } from '@mui/material';
import { Button as CustomButton } from './components/Button.js';
```

Reference: [Google JavaScript Style Guide - Naming imports](https://google.github.io/styleguide/jsguide.html#naming-module-local-names)
