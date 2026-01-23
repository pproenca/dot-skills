---
title: Separate Construction from Use
impact: MEDIUM
impactDescription: enables testing and reduces coupling
tags: class, construction, factories, separation
---

## Separate Construction from Use

The startup process of object construction is a separate concern from runtime logic. Applications should separate the main function (which builds objects) from the rest of the system (which uses them).

**Incorrect (construction mixed with use):**

```java
public class OrderProcessor {
    public void processOrder(Order order) {
        // Construction buried in business logic
        EmailService emailService = new SmtpEmailService(
            "smtp.example.com", 587, "user", "password");
        InventoryService inventory = new InventoryServiceImpl(
            new PostgresConnection("localhost", 5432));
        PaymentGateway gateway = new StripeGateway(API_KEY);

        // Business logic
        inventory.reserve(order.getItems());
        gateway.charge(order.getPayment());
        emailService.sendConfirmation(order);
    }
}
```

**Correct (construction separated from use):**

```java
// Main builds the object graph
public class Application {
    public static void main(String[] args) {
        EmailService emailService = new SmtpEmailService(
            Config.get("smtp.host"), Config.getInt("smtp.port"));
        InventoryService inventory = new InventoryServiceImpl(
            new PostgresConnection(Config.get("db.url")));
        PaymentGateway gateway = new StripeGateway(Config.get("stripe.key"));

        OrderProcessor processor = new OrderProcessor(
            emailService, inventory, gateway);

        processor.start();
    }
}

// Business class receives dependencies
public class OrderProcessor {
    private final EmailService emailService;
    private final InventoryService inventory;
    private final PaymentGateway gateway;

    public OrderProcessor(EmailService email, InventoryService inv,
                          PaymentGateway pay) {
        this.emailService = email;
        this.inventory = inv;
        this.gateway = pay;
    }

    public void processOrder(Order order) {
        inventory.reserve(order.getItems());
        gateway.charge(order.getPayment());
        emailService.sendConfirmation(order);
    }
}
```

**Alternative:** Use Dependency Injection frameworks (Spring, Guice) to manage construction.

Reference: [Clean Code, Chapter 11: Systems](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
