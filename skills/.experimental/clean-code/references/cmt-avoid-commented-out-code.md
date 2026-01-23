---
title: Delete Commented-Out Code
impact: HIGH
impactDescription: prevents code archaeology confusion
tags: cmt, dead-code, version-control, clutter
---

## Delete Commented-Out Code

Commented-out code is an abomination. Others who see it will not have the courage to delete it. They think it must be there for a reason. It rots and becomes increasingly irrelevant.

**Incorrect (commented-out code persisting):**

```java
public void processOrder(Order order) {
    validateOrder(order);
    // calculateLegacyDiscount(order);
    // if (order.getCustomer().isPremium()) {
    //     applyPremiumDiscount(order);
    // }
    calculateDiscount(order);
    // sendNotification(order);
    // logOrderDetails(order);
    saveOrder(order);
    notifyWarehouse(order);
}
```

**Correct (clean code, trust version control):**

```java
public void processOrder(Order order) {
    validateOrder(order);
    calculateDiscount(order);
    saveOrder(order);
    notifyWarehouse(order);
}
```

**Why delete it?**
- Version control remembers everything
- Commented code creates confusion: Is it needed? Why is it there?
- It clutters the file and makes scanning harder
- It becomes stale and misleading over time

**If you really need it:** Create a git branch, or add a reference comment pointing to the commit where it was removed.

Reference: [Clean Code, Chapter 4: Comments](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
