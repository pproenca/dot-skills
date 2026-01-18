---
title: Use lowerCamelCase for Methods and Variables
impact: HIGH
impactDescription: maintains consistency and enables code search
tags: naming, methods, variables, camelcase
---

## Use lowerCamelCase for Methods and Variables

Method names, parameter names, and local variables use lowerCamelCase. Names are descriptive verbs for methods and descriptive nouns for variables.

**Incorrect (wrong casing or unclear names):**

```javascript
class OrderService {
  // Snake_case method
  get_order_by_id(order_id) {
    return this.database.find(order_id);
  }

  // ALL_CAPS for non-constant
  ProcessOrders(ORDERS) {
    for (const ORDER of ORDERS) {
      this.process(ORDER);
    }
  }

  // Unclear abbreviations
  updUsrPrf(u, p) {
    u.profile = p;
  }
}
```

**Correct (lowerCamelCase with descriptive names):**

```javascript
class OrderService {
  getOrderById(orderId) {
    return this.database.find(orderId);
  }

  processOrders(orders) {
    for (const order of orders) {
      this.process(order);
    }
  }

  updateUserProfile(user, profile) {
    user.profile = profile;
  }
}
```

**Method naming patterns:**
- Getters: `getUser()`, `fetchOrders()`, `loadConfig()`
- Boolean getters: `isActive()`, `hasPermission()`, `canEdit()`
- Setters: `setTheme()`, `updateStatus()`, `assignRole()`
- Actions: `processOrder()`, `validateInput()`, `sendEmail()`

Reference: [Google JavaScript Style Guide - Method names](https://google.github.io/styleguide/jsguide.html#naming-method-names)
