---
title: Limit Lines to 80 Characters
impact: LOW
impactDescription: prevents horizontal scrolling in 80-column terminals
tags: format, line-length, column-limit, style
---

## Limit Lines to 80 Characters

Keep lines under 80 characters. Long lines are hard to read and cause horizontal scrolling in code review tools and split-pane editors.

**Incorrect (exceeds 80 characters):**

```javascript
const userNotificationMessage = `Dear ${user.firstName}, your order #${order.id} has been shipped and will arrive by ${order.estimatedDelivery}`;

function processPaymentWithRetryAndNotification(userId, orderId, paymentMethod, billingAddress, shippingAddress) {
  // Long parameter list
}

import { validateUser, validateOrder, validatePayment, validateShipping, validateBilling } from './validators.js';
```

**Correct (wrapped at 80 characters):**

```javascript
const userNotificationMessage =
    `Dear ${user.firstName}, your order #${order.id} has been ` +
    `shipped and will arrive by ${order.estimatedDelivery}`;

function processPaymentWithRetryAndNotification(
    userId,
    orderId,
    paymentMethod,
    billingAddress,
    shippingAddress
) {
  // Parameters on separate lines
}

import {
  validateUser,
  validateOrder,
  validatePayment,
  validateShipping,
  validateBilling,
} from './validators.js';
```

**Exceptions (no line-wrapping required):**
- `import` and `export` statements (but wrapping is preferred)
- Long URLs in comments
- Shell commands in comments
- Long string literals that cannot be split

Reference: [Google JavaScript Style Guide - Column limit](https://google.github.io/styleguide/jsguide.html#formatting-column-limit)
