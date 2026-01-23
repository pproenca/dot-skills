---
title: Build Anti-Corruption Layers for External Systems
impact: MEDIUM
impactDescription: protects domain from external model pollution
tags: adapt, anti-corruption, external, isolation
---

## Build Anti-Corruption Layers for External Systems

When integrating with external systems that have different models, build an anti-corruption layer (ACL) that translates between their model and yours. Never let external concepts pollute your domain.

**Incorrect (external model leaks into domain):**

```java
// Domain polluted with Stripe's model
public class Order {
    private String id;
    private List<OrderItem> items;
    // Stripe-specific fields in domain
    private String stripeCustomerId;
    private String stripePaymentIntentId;
    private String stripePaymentMethodId;

    public void processPayment(Stripe stripe) {
        // Domain directly calls Stripe
        PaymentIntent intent = PaymentIntent.create(
            PaymentIntentCreateParams.builder()
                .setCustomer(this.stripeCustomerId)
                .setPaymentMethod(this.stripePaymentMethodId)
                .setAmount(this.calculateTotal().cents())
                .setCurrency("usd")
                .build()
        );
        this.stripePaymentIntentId = intent.getId();
    }
}

// If we switch to PayPal, Order must change
```

**Correct (anti-corruption layer isolates external model):**

```java
// domain/Order.java - Pure domain, no external concepts
public class Order {
    private OrderId id;
    private CustomerId customerId;
    private List<OrderItem> items;
    private PaymentStatus paymentStatus;

    public Money calculateTotal() {
        return items.stream()
            .map(OrderItem::lineTotal)
            .reduce(Money.zero(), Money::add);
    }

    public void markPaid(PaymentReference reference) {
        this.paymentStatus = PaymentStatus.paid(reference);
    }
}

// domain/ports/PaymentProcessor.java - Domain-defined port
public interface PaymentProcessor {
    PaymentResult charge(CustomerId customer, Money amount);
}

// Domain-defined value objects
public record PaymentResult(PaymentReference reference, PaymentStatus status) {}
public record PaymentReference(String value) {}

// infrastructure/stripe/StripePaymentProcessor.java - ACL
public class StripePaymentProcessor implements PaymentProcessor {
    private final CustomerMappingRepository customerMapping;

    public PaymentResult charge(CustomerId customerId, Money amount) {
        // Translate domain CustomerId to Stripe customer
        String stripeCustomerId = customerMapping.getStripeId(customerId);

        // Call Stripe with their model
        PaymentIntent intent = PaymentIntent.create(
            PaymentIntentCreateParams.builder()
                .setCustomer(stripeCustomerId)
                .setAmount(amount.cents())
                .setCurrency("usd")
                .setConfirm(true)
                .build()
        );

        // Translate Stripe response back to domain model
        return new PaymentResult(
            new PaymentReference(intent.getId()),
            translateStatus(intent.getStatus())
        );
    }

    private PaymentStatus translateStatus(String stripeStatus) {
        return switch (stripeStatus) {
            case "succeeded" -> PaymentStatus.COMPLETED;
            case "processing" -> PaymentStatus.PENDING;
            case "requires_action" -> PaymentStatus.REQUIRES_ACTION;
            default -> PaymentStatus.FAILED;
        };
    }
}
```

**Benefits:**
- Domain model remains clean and business-focused
- Switch payment providers by implementing new ACL
- External API changes isolated to ACL

Reference: [Anti-Corruption Layer Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer)
