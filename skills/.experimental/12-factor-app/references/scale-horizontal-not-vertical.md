---
title: Design for Horizontal Scaling Over Vertical Scaling
impact: HIGH
impactDescription: enables cost-effective scaling, eliminates single points of failure
tags: scale, horizontal, vertical, architecture
---

## Design for Horizontal Scaling Over Vertical Scaling

A twelve-factor app scales horizontally by adding more processes, not vertically by adding more resources to a single process. While individual processes can use threads or async I/O internally, the primary scaling mechanism is running more process instances.

**Incorrect (vertical scaling approach):**

```python
# Design assumes single big server
class OrderProcessor:
    def __init__(self):
        # In-memory cache - can't share across processes
        self.order_cache = {}
        # Locks assume single process
        self.lock = threading.Lock()

    def process_order(self, order):
        with self.lock:  # Only works in single process
            if order.id in self.order_cache:
                return self.order_cache[order.id]
            result = self._expensive_process(order)
            self.order_cache[order.id] = result
            return result

# Scale by getting bigger server
# Eventually hit ceiling - can't scale further
# Single point of failure
```

**Correct (horizontal scaling approach):**

```python
import redis
import os

redis_client = redis.from_url(os.environ['REDIS_URL'])

class OrderProcessor:
    def process_order(self, order):
        # Distributed lock via Redis
        lock = redis_client.lock(f'order:{order.id}', timeout=30)
        if lock.acquire(blocking=True, blocking_timeout=5):
            try:
                # Check distributed cache
                cached = redis_client.get(f'result:{order.id}')
                if cached:
                    return json.loads(cached)

                result = self._expensive_process(order)

                # Store in distributed cache
                redis_client.setex(
                    f'result:{order.id}',
                    3600,
                    json.dumps(result)
                )
                return result
            finally:
                lock.release()

# Scale by adding more processes
# Works across multiple servers
# No single point of failure
```

**Scaling strategies:**

```yaml
# Kubernetes HPA - auto-scale horizontally
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 100
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
# Add pods when CPU > 70%, remove when lower
```

```bash
# Manual horizontal scaling
kubectl scale deployment web --replicas=20
# Heroku
heroku ps:scale web=20
```

**Benefits:**
- No upper limit on capacity (cloud has more servers)
- Cost-effective (small instances are cheaper per unit)
- Resilient (losing one process doesn't lose all capacity)
- Geographic distribution possible

Reference: [The Twelve-Factor App - Concurrency](https://12factor.net/concurrency)
