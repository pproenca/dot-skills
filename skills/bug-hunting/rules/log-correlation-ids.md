---
title: Add Correlation IDs Across Services
impact: HIGH
impactDescription: enables cross-service debugging in seconds
tags: log, correlation, distributed, tracing
---

## Add Correlation IDs Across Services

Generate a unique correlation ID at the entry point and propagate it through all services and log entries. This enables tracing a single request across microservices, queues, and databases.

**Incorrect (isolated logs, can't trace requests):**

```javascript
// Service A
logger.info('Received order request')  // Which request?

// Service B
logger.info('Processing payment')       // For which order?

// Service C
logger.error('Inventory check failed')  // Related to which request?

// Debugging: "Which payment corresponds to which inventory failure?"
// Answer: No way to know
```

**Correct (correlation ID links all logs):**

```javascript
// API Gateway: Generate correlation ID
app.use((req, res, next) => {
  req.correlationId = req.headers['x-correlation-id'] || uuid()
  res.setHeader('x-correlation-id', req.correlationId)
  next()
})

// Service A
logger.info('Received order request', {
  correlationId: req.correlationId,
  userId: req.userId
})

// Service B (receives correlationId in header)
logger.info('Processing payment', {
  correlationId: req.headers['x-correlation-id'],
  amount: payment.amount
})

// Service C
logger.error('Inventory check failed', {
  correlationId: message.correlationId,
  productId: item.productId,
  error: 'Out of stock'
})

// Query: correlationId:"abc-123-def"
// Result: Complete request trace across all services
```

**Propagation points:**
- HTTP headers: `X-Correlation-ID`
- Message queues: Include in message metadata
- Database: Log correlation ID with slow query warnings
- Background jobs: Pass via job context

Reference: [BetterStack - Logging vs Metrics vs Tracing](https://betterstack.com/community/guides/observability/logging-metrics-tracing/)
