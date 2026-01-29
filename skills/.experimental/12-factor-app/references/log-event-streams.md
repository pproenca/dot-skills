---
title: Treat Logs as Event Streams Not Files
impact: MEDIUM
impactDescription: enables log aggregation, real-time analysis, cloud-native deployment
tags: log, streams, stdout, observability
---

## Treat Logs as Event Streams Not Files

A twelve-factor app produces logs as a stream of time-ordered events, writing unbuffered to stdout. The app never concerns itself with routing or storage of its output stream - that's the responsibility of the execution environment.

**Incorrect (app manages log files):**

```python
import logging
from logging.handlers import RotatingFileHandler

# App manages its own log files
handler = RotatingFileHandler(
    '/var/log/myapp/app.log',
    maxBytes=10000000,
    backupCount=5
)
logger = logging.getLogger()
logger.addHandler(handler)

# Problems:
# - Container filesystem is ephemeral - logs lost on restart
# - Need to configure log rotation
# - Need to ship logs to aggregator separately
# - Different config per environment
# - Permission issues with /var/log
```

**Correct (write to stdout):**

```python
import logging
import sys

# Configure logging to stdout
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(name)s %(message)s'
)

logger = logging.getLogger(__name__)

def process_order(order_id):
    logger.info(f"Processing order {order_id}")
    # ... do work ...
    logger.info(f"Order {order_id} completed")

# stdout captured by:
# - Docker: docker logs container_name
# - Kubernetes: kubectl logs pod_name
# - Heroku: heroku logs --tail
# - systemd: journalctl -u myapp
```

**JSON structured logging:**

```python
import logging
import json
import sys

class JSONFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'extra': getattr(record, 'extra', {}),
        })

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JSONFormatter())
logging.root.handlers = [handler]

logger = logging.getLogger(__name__)
logger.info("Order processed", extra={'extra': {'order_id': 123, 'amount': 99.99}})
# Output: {"timestamp": "2024-01-15 14:30:00", "level": "INFO", "logger": "__main__", "message": "Order processed", "extra": {"order_id": 123, "amount": 99.99}}
```

**Environment captures and routes:**

```yaml
# Kubernetes - logs go to stdout, platform routes
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    # App writes to stdout
    # Kubernetes captures and stores
    # Can ship to: Elasticsearch, Datadog, CloudWatch, etc.

# Docker Compose - logs to stdout
services:
  app:
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    # Or ship to external service
    # driver: fluentd
    # options:
    #   fluentd-address: "localhost:24224"
```

**Benefits:**
- App code is simple - just write to stdout
- Same code works in any environment
- Platform handles aggregation, rotation, shipping
- Real-time streaming and historical analysis

Reference: [The Twelve-Factor App - Logs](https://12factor.net/logs)
