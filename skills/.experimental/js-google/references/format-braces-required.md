---
title: Always Use Braces for Control Structures
impact: LOW
impactDescription: prevents bugs when adding statements
tags: format, braces, control-structures, style
---

## Always Use Braces for Control Structures

Use braces for all control structures (`if`, `else`, `for`, `while`, `do`) even when the body is a single statement. This prevents bugs when adding statements later.

**Incorrect (missing braces):**

```javascript
function validateOrder(order) {
  if (!order.items)
    return false;

  for (const item of order.items)
    if (item.quantity <= 0)
      return false;  // Easy to break when adding logging

  if (order.total > 10000)
    applyDiscount(order);
    sendNotification(order);  // Always runs! Not part of if
}
```

**Correct (braces required):**

```javascript
function validateOrder(order) {
  if (!order.items) {
    return false;
  }

  for (const item of order.items) {
    if (item.quantity <= 0) {
      return false;
    }
  }

  if (order.total > 10000) {
    applyDiscount(order);
    sendNotification(order);  // Clearly part of if block
  }
}
```

**Exception (simple single-line if):**

```javascript
// OK when condition and body fit on one line with braces
if (!user) { return null; }

// Also acceptable
if (!user) {
  return null;
}
```

**Brace style (K&R):**
- Opening brace on same line as statement
- Closing brace on its own line
- `else` on same line as closing brace

Reference: [Google JavaScript Style Guide - Braces](https://google.github.io/styleguide/jsguide.html#formatting-braces)
