---
title: Design for Testability From the Start
impact: LOW-MEDIUM
impactDescription: enables comprehensive testing without test-induced damage
tags: test, testability, design, interfaces
---

## Design for Testability From the Start

Clean architecture makes testing easy by design. If something is hard to test, it's a sign of architectural coupling. Don't compromise architecture for testability; fix the coupling.

**Incorrect (hard to test, requiring workarounds):**

```java
public class OrderProcessor {
    public void process(Order order) {
        // Hard to test: direct instantiation
        PaymentService payment = new PaymentService();

        // Hard to test: static call
        if (InventoryChecker.isAvailable(order.getItems())) {

            // Hard to test: singleton
            payment.charge(order.getTotal());
            NotificationService.getInstance().sendConfirmation(order);

            // Hard to test: current time
            order.setProcessedAt(new Date());
        }
    }
}

// Test requires PowerMock, static mocking, singleton reset
// Test is slow, brittle, and complicated
@Test
@PrepareForTest({InventoryChecker.class, NotificationService.class})
public void testProcess() {
    PowerMockito.mockStatic(InventoryChecker.class);
    PowerMockito.when(InventoryChecker.isAvailable(any())).thenReturn(true);
    // ... 20 more lines of mock setup
}
```

**Correct (testable by design):**

```java
public class OrderProcessor {
    private final InventoryChecker inventory;
    private final PaymentGateway payment;
    private final NotificationPort notification;
    private final Clock clock;

    // All dependencies injected - easy to substitute
    public OrderProcessor(
        InventoryChecker inventory,
        PaymentGateway payment,
        NotificationPort notification,
        Clock clock
    ) {
        this.inventory = inventory;
        this.payment = payment;
        this.notification = notification;
        this.clock = clock;
    }

    public ProcessResult process(Order order) {
        if (!inventory.isAvailable(order.getItems())) {
            return ProcessResult.unavailable();
        }

        PaymentResult paymentResult = payment.charge(order.getTotal());
        if (!paymentResult.isSuccessful()) {
            return ProcessResult.paymentFailed(paymentResult.getError());
        }

        order.markProcessed(clock.now());
        notification.sendConfirmation(order);

        return ProcessResult.success(order);
    }
}

@Test
void processesOrderWhenInventoryAvailable() {
    var inventory = StubInventory.withAvailability(true);
    var payment = FakePaymentGateway.alwaysSucceeds();
    var notification = new SpyNotification();
    var clock = Clock.fixed(Instant.parse("2024-01-15T10:00:00Z"), ZoneOffset.UTC);

    var processor = new OrderProcessor(inventory, payment, notification, clock);
    var result = processor.process(order);

    assertThat(result.isSuccessful()).isTrue();
}
```

**Testability checklist:**
- [ ] No `new` for services (inject dependencies)
- [ ] No static method calls for behavior (use interfaces)
- [ ] No singletons (pass instances)
- [ ] No direct time/random access (inject Clock, Random)
- [ ] No hidden dependencies (everything in constructor)

Reference: [Growing Object-Oriented Software, Guided by Tests](http://www.growing-object-oriented-software.com/)
