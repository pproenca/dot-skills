---
title: Use Structured Logging for Machine-Readable Event Streams
impact: MEDIUM
impactDescription: enables field-based querying, aggregation, and automated alerting
tags: log, structured, json, observability
---

## Use Structured Logging for Machine-Readable Event Streams

While plain text logs are human-readable, structured logs (JSON) enable field-based querying, filtering, and analysis in log aggregation systems. Each log event becomes a queryable document with typed fields.

**Incorrect (unstructured text logs):**

```python
logger.info(f"User {user_id} placed order {order_id} for ${amount}")
# Output: 2024-01-15 14:30:00 INFO User 123 placed order 456 for $99.99

# Problems:
# - Need regex to extract user_id, order_id, amount
# - Queries like "orders over $100" are difficult
# - Inconsistent formats across messages
# - Hard to correlate events
```

**Correct (structured JSON logs):**

```python
import logging
import json
import sys
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
        }
        # Add extra fields
        if hasattr(record, 'extra'):
            log_data.update(record.extra)
        return json.dumps(log_data)

# Configure root logger
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JSONFormatter())
logging.root.handlers = [handler]
logging.root.setLevel(logging.INFO)

logger = logging.getLogger(__name__)

# Log with structured data
logger.info("Order placed", extra={
    'event': 'order.placed',
    'user_id': 123,
    'order_id': 456,
    'amount': 99.99,
    'currency': 'USD',
})
# Output: {"timestamp": "2024-01-15T14:30:00.000Z", "level": "INFO", "logger": "__main__", "message": "Order placed", "event": "order.placed", "user_id": 123, "order_id": 456, "amount": 99.99, "currency": "USD"}
```

**Using structlog for better ergonomics:**

```python
import structlog

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.BoundLogger,
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
)

logger = structlog.get_logger()

# Clean syntax for structured logging
logger.info("order.placed", user_id=123, order_id=456, amount=99.99)
# Output: {"event": "order.placed", "user_id": 123, "order_id": 456, "amount": 99.99, "timestamp": "2024-01-15T14:30:00.000000Z"}

# Bind context that persists across calls
log = logger.bind(request_id="abc-123", user_id=123)
log.info("processing started")
log.info("step completed", step="validation")
log.info("processing finished")
# All three have request_id and user_id
```

**Query structured logs:**

```text
# Elasticsearch/Kibana queries
event:order.placed AND amount:>100

# Datadog queries
@event:order.placed @amount:>100

# CloudWatch Insights
fields @timestamp, @message
| filter event = 'order.placed' and amount > 100
| stats count(*) by user_id
```

**Benefits:**
- Query specific fields without regex
- Aggregate and analyze (orders per user, avg amount)
- Create alerts on specific conditions
- Correlate events by request_id or user_id

Reference: [The Twelve-Factor App - Logs](https://12factor.net/logs)
