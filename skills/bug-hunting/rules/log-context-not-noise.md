---
title: Log Context Not Noise
impact: HIGH
impactDescription: 5-10× reduction in log volume
tags: log, context, signal, noise-reduction
---

## Log Context Not Noise

Log the information needed to understand what happened and debug issues, but avoid logging everything. Focus on decision points, state changes, and error context rather than routine operations.

**Incorrect (logging everything):**

```java
public Order processOrder(OrderRequest request) {
    log.info("Entering processOrder");                    // Noise
    log.info("Request received: " + request);             // Noise
    log.info("Validating order");                         // Noise

    for (Item item : request.getItems()) {
        log.info("Processing item: " + item.getId());     // N logs per order
        log.info("Item price: " + item.getPrice());       // More noise
        log.info("Item quantity: " + item.getQuantity()); // Even more noise
    }

    log.info("Calculating total");                        // Noise
    log.info("Total calculated: " + total);               // Useful for debugging
    log.info("Saving order");                             // Noise
    log.info("Order saved");                              // Noise
    log.info("Exiting processOrder");                     // Noise
    return order;
}
// 10+ log lines per order, mostly useless in debugging
```

**Correct (contextual logging):**

```java
public Order processOrder(OrderRequest request) {
    log.info("order_received",
             orderId, request.getOrderId(),
             userId, request.getUserId(),
             itemCount, request.getItems().size());

    try {
        Order order = orderService.create(request);

        log.info("order_created",
                 orderId, order.getId(),
                 total, order.getTotal(),
                 status, order.getStatus());

        return order;
    } catch (ValidationException e) {
        log.warn("order_validation_failed",
                 orderId, request.getOrderId(),
                 reason, e.getMessage(),
                 field, e.getField());         // Context for debugging
        throw e;
    } catch (Exception e) {
        log.error("order_processing_failed",
                  orderId, request.getOrderId(),
                  errorType, e.getClass().getSimpleName(),
                  errorMessage, e.getMessage());
        throw e;
    }
}
// 1-2 log lines per order, all meaningful
```

**Log these:**
- Request received (with key identifiers)
- Major state changes
- Decision branches taken
- Errors with full context

Reference: [Sentry Blog - Observability and Tracing](https://blog.sentry.io/observability-and-tracing-how-to-improve-your-debugging-workflow/)
