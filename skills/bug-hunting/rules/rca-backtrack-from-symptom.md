---
title: Backtrack from Symptom to Source
impact: HIGH
impactDescription: O(log n) search through data flow
tags: rca, backtracking, data-flow, tracing
---

## Backtrack from Symptom to Source

Start from where the bug manifests and trace backwards through the code, following data flow in reverse. Each step asks: "Where did this incorrect value come from?"

**Incorrect (forward search from random starting point):**

```javascript
// Bug: User sees "$NaN" for order total
// Approach: Start reading code from the beginning

// order-creation.js - Looks fine
// cart-service.js - Looks fine
// pricing-engine.js - Looks fine
// ... eventually give up
```

**Correct (backtrack from the symptom):**

```javascript
// Bug: User sees "$NaN" for order total
// Approach: Start where NaN appears, trace backwards

// Step 1: Where is "$NaN" rendered?
// OrderSummary.jsx line 45
const total = formatCurrency(order.total)  // order.total is NaN

// Step 2: Where does order.total come from?
// order-service.js line 120
order.total = subtotal + shipping + tax     // shipping is NaN

// Step 3: Where does shipping come from?
// shipping-calculator.js line 55
const shipping = rates[zone]                 // zone is "UNKNOWN"

// Step 4: Where does zone come from?
// address-service.js line 30
const zone = getShippingZone(address.zipCode) // zipCode is undefined

// ROOT CAUSE: Missing zipCode validation in address form
```

**Backtracking process:**
1. Locate the symptom (where bad output appears)
2. Find the variable containing the bad value
3. Find where that variable was assigned
4. Repeat until you find the first incorrect value
5. That assignment is the bug

Reference: [GeeksforGeeks - Debugging Approaches](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)
