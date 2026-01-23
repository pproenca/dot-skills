---
title: Declare All Dependencies Explicitly in Constructor
impact: HIGH
impactDescription: enables testing, documents requirements, prevents hidden coupling
tags: usecase, dependencies, constructor, injection
---

## Declare All Dependencies Explicitly in Constructor

Use cases should receive all dependencies through their constructor. Hidden dependencies (service locators, singletons, static calls) make testing difficult and hide coupling.

**Incorrect (hidden dependencies):**

```java
public class PlaceOrderUseCase {
    public OrderConfirmation execute(PlaceOrderCommand command) {
        // Hidden dependencies - impossible to test or trace
        var customer = CustomerRepository.getInstance().find(command.customerId());
        var inventory = InventoryService.getInventory();

        for (var item : command.items()) {
            if (!inventory.isAvailable(item)) {
                throw new OutOfStockException(item);
            }
        }

        var order = new Order(customer, command.items());

        // More hidden dependencies
        Database.getConnection().save(order);
        EmailService.send(customer.email(), "Order placed");
        EventBus.publish(new OrderPlacedEvent(order));

        return new OrderConfirmation(order.id());
    }
}

// Testing requires mocking static methods - complex and brittle
```

**Correct (explicit constructor dependencies):**

```java
public class PlaceOrderUseCase {
    private final CustomerRepository customers;
    private final InventoryChecker inventory;
    private final OrderRepository orders;
    private final NotificationPort notifications;
    private final EventPublisher events;

    public PlaceOrderUseCase(
        CustomerRepository customers,
        InventoryChecker inventory,
        OrderRepository orders,
        NotificationPort notifications,
        EventPublisher events
    ) {
        this.customers = customers;
        this.inventory = inventory;
        this.orders = orders;
        this.notifications = notifications;
        this.events = events;
    }

    public OrderConfirmation execute(PlaceOrderCommand command) {
        var customer = customers.find(command.customerId());

        for (var item : command.items()) {
            if (!inventory.isAvailable(item)) {
                throw new OutOfStockException(item);
            }
        }

        var order = new Order(customer, command.items());
        orders.save(order);

        notifications.orderPlaced(customer, order);
        events.publish(new OrderPlacedEvent(order));

        return new OrderConfirmation(order.id());
    }
}

// Testing is straightforward
@Test
void placesOrderWhenInventoryAvailable() {
    var customers = mock(CustomerRepository.class);
    var inventory = mock(InventoryChecker.class);
    var orders = mock(OrderRepository.class);
    // ... configure mocks

    var useCase = new PlaceOrderUseCase(customers, inventory, orders, ...);
    var result = useCase.execute(command);

    verify(orders).save(any(Order.class));
}
```

**Benefits:**
- Dependencies visible in constructor signature
- Tests substitute any dependency with test doubles
- Coupling is explicit and measurable

Reference: [Dependency Injection Principles](https://martinfowler.com/articles/injection.html)
