---
title: Use Build-Operate-Check Pattern
impact: MEDIUM
impactDescription: reduces test comprehension time by 50%
tags: test, boc, arrange-act-assert, structure
---

## Use Build-Operate-Check Pattern

Structure tests in three distinct phases: Build (arrange), Operate (act), Check (assert). This pattern makes tests easy to read and understand at a glance.

**Incorrect (mixed phases, unclear structure):**

```java
@Test
public void testOrder() {
    Order order = new Order();
    assertTrue(order.isEmpty());
    Product product = new Product("Widget", 9.99);
    order.add(product);
    assertEquals(1, order.getItemCount());
    assertEquals(9.99, order.getTotal(), 0.01);
    order.add(product);
    assertEquals(2, order.getItemCount());
    assertEquals(19.98, order.getTotal(), 0.01);
}
```

**Correct (clear Build-Operate-Check):**

```java
@Test
public void addingProductShouldIncreaseItemCount() {
    // Build
    Order order = new Order();
    Product widget = new Product("Widget", 9.99);

    // Operate
    order.add(widget);

    // Check
    assertEquals(1, order.getItemCount());
}

@Test
public void addingProductShouldUpdateTotal() {
    // Build
    Order order = new Order();
    Product widget = new Product("Widget", 9.99);

    // Operate
    order.add(widget);

    // Check
    assertEquals(9.99, order.getTotal(), 0.01);
}

@Test
public void addingSameProductTwiceShouldDoubleTotal() {
    // Build
    Order order = new Order();
    Product widget = new Product("Widget", 9.99);

    // Operate
    order.add(widget);
    order.add(widget);

    // Check
    assertEquals(19.98, order.getTotal(), 0.01);
}
```

**Alias patterns:**
- Build-Operate-Check (BOC)
- Arrange-Act-Assert (AAA)
- Given-When-Then (BDD)

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
