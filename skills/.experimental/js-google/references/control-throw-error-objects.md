---
title: Always Throw Error Objects, Not Primitives
impact: MEDIUM-HIGH
impactDescription: preserves stack traces for debugging
tags: control, exceptions, error, throw
---

## Always Throw Error Objects, Not Primitives

Always throw `Error` objects or subclasses, never strings or plain objects. Error objects capture stack traces essential for debugging.

**Incorrect (throwing primitives loses stack trace):**

```javascript
function validateOrder(order) {
  if (!order.items || order.items.length === 0) {
    throw 'Order must have items';  // No stack trace
  }
  if (order.total < 0) {
    throw { code: 'INVALID_TOTAL', message: 'Total cannot be negative' };
  }
}

async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw response.status;  // Just a number, useless for debugging
  }
}
```

**Correct (throw Error objects):**

```javascript
function validateOrder(order) {
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items');
  }
  if (order.total < 0) {
    throw new RangeError('Total cannot be negative');
  }
}

class ApiError extends Error {
  constructor(status, message) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
  }
}

async function fetchUserData(userId) {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw new ApiError(response.status, `Failed to fetch user: ${userId}`);
  }
  return response.json();
}
```

**Built-in Error types:**
- `Error` - generic errors
- `TypeError` - type mismatches
- `RangeError` - out of range values
- `ReferenceError` - undefined variable access

Reference: [Google JavaScript Style Guide - Exceptions](https://google.github.io/styleguide/jsguide.html#features-exceptions)
