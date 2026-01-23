---
title: Provide Context with Exceptions
impact: MEDIUM-HIGH
impactDescription: enables rapid root cause identification
tags: err, context, messages, debugging
---

## Provide Context with Exceptions

Each exception should provide enough context to determine the source and location of an error. Create informative error messages that describe the operation that failed and the type of failure.

**Incorrect (no context):**

```java
throw new Exception("Error occurred");

throw new RuntimeException("Failed");

throw new DataAccessException("Query failed");

// Stack trace alone doesn't tell you which order, which customer
catch (SQLException e) {
    throw new RuntimeException(e);
}
```

**Correct (rich context):**

```java
throw new OrderProcessingException(
    String.format("Failed to process order %s for customer %s: %s",
        orderId, customerId, "Insufficient inventory for item SKU-12345"));

throw new ConfigurationException(
    "Cannot load configuration from " + configPath +
    ". Expected format: YAML. Check file permissions and syntax.");

catch (SQLException e) {
    throw new DataAccessException(
        String.format("Failed to insert order %s into table %s. " +
            "Constraint violated: %s",
            order.getId(), "orders", e.getMessage()),
        e);  // Preserve original exception
}
```

**Include in exception messages:**
- What operation was being attempted
- What data was involved (IDs, names, quantities)
- Why it failed (the specific error condition)
- Preserve the original exception when wrapping

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
