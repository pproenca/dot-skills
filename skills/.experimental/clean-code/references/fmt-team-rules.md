---
title: Follow Team Formatting Rules
impact: HIGH
impactDescription: eliminates style-related code review friction
tags: fmt, team, consistency, standards
---

## Follow Team Formatting Rules

A team of developers should agree upon a single formatting style. Every member should use that style. The goal is to make the software have a consistent style, as if written by one person.

**Incorrect (inconsistent styles mixed):**

```java
// Developer A's style
public void processOrder(Order order){
    if(order.isValid()){
        order.process();
    }
}

// Developer B's style
public void processPayment( Payment payment )
{
    if ( payment.isValid() )
    {
        payment.process();
    }
}

// Developer C's style
public void processShipment(Shipment shipment) {
  if (shipment.isValid()) {
    shipment.process(); }}
```

**Correct (consistent team style):**

```java
public void processOrder(Order order) {
    if (order.isValid()) {
        order.process();
    }
}

public void processPayment(Payment payment) {
    if (payment.isValid()) {
        payment.process();
    }
}

public void processShipment(Shipment shipment) {
    if (shipment.isValid()) {
        shipment.process();
    }
}
```

**Implementation:**
- Document the team's coding standards
- Use automated formatters (Prettier, Black, google-java-format)
- Enforce in CI/CD pipelines
- Configure IDE to format on save

Your personal style preferences are less important than team consistency.

Reference: [Clean Code, Chapter 5: Formatting](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
