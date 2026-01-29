---
title: Assign Workloads to Appropriate Process Types
impact: HIGH
impactDescription: optimizes resource usage, enables targeted scaling
tags: scale, process-types, workloads, architecture
---

## Assign Workloads to Appropriate Process Types

Architect your application with distinct process types for different workloads. Web processes handle HTTP requests. Worker processes handle background jobs. Clock processes handle scheduled tasks. Each type can be tuned and scaled for its specific workload.

**Incorrect (single process type handles all workloads):**

```python
# Everything in one process
from flask import Flask
from threading import Thread

app = Flask(__name__)

@app.route('/api/orders', methods=['POST'])
def create_order():
    order_data = request.json
    # Blocking: process order inline, user waits
    process_order(order_data)  # Takes 30 seconds
    return {"status": "complete"}

# Background worker in same process
def worker_loop():
    while True:
        job = get_next_job()
        process_job(job)

Thread(target=worker_loop).start()
app.run()
# Can't scale web and workers independently
```

**Correct (distinct process types for each workload):**

```yaml
# Procfile with distinct process types
web: gunicorn api:app --workers 4 --timeout 30
worker: celery -A tasks worker -Q default,high_priority
worker_slow: celery -A tasks worker -Q slow_jobs --concurrency 2
scheduler: celery -A tasks beat
```

**Process type patterns:

```yaml
# Procfile with distinct process types
web: gunicorn api:app --workers 4 --timeout 30
worker: celery -A tasks worker -Q default,high_priority
worker_slow: celery -A tasks worker -Q slow_jobs --concurrency 2
scheduler: celery -A tasks beat
```

**Web process (optimized for request/response):**

```python
# Fast, concurrent, handles many requests
# Short timeout, fails fast
# Stateless, horizontal scaling

from flask import Flask
import os

app = Flask(__name__)

@app.route('/api/orders', methods=['POST'])
def create_order():
    # Quick validation and queuing
    order_data = request.json
    validate_order(order_data)  # Fast, synchronous
    process_order.delay(order_data)  # Async to worker
    return {"status": "accepted"}, 202
```

**Worker process (optimized for throughput):**

```python
# Long-running tasks, CPU or I/O intensive
# Can have longer timeout
# Scale based on queue depth

from celery import Celery

app = Celery('tasks')

@app.task(queue='default')
def process_order(order_data):
    # Can take minutes without blocking web
    inventory = check_inventory(order_data)
    payment = charge_payment(order_data)
    shipping = create_shipment(order_data)
    send_confirmation_email(order_data)

@app.task(queue='slow_jobs')
def generate_report(params):
    # Very slow, isolated to separate queue
    data = query_large_dataset(params)
    report = compile_report(data)
    upload_to_s3(report)
```

**Scheduler process (triggers timed work):**

```python
# celery beat config
app.conf.beat_schedule = {
    'cleanup-every-hour': {
        'task': 'tasks.cleanup',
        'schedule': 3600.0,  # Every hour
    },
    'daily-report': {
        'task': 'tasks.generate_daily_report',
        'schedule': crontab(hour=0, minute=0),  # Midnight
    },
}
# Scheduler only triggers tasks, doesn't execute them
# Single instance to avoid duplicate scheduling
```

**Scaling by type:**

```yaml
# kubernetes deployment per process type
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 5  # Handle traffic
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
spec:
  replicas: 10  # Process job backlog
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scheduler
spec:
  replicas: 1  # Only one scheduler
```

**Benefits:**
- Tune each process type for its workload
- Scale independently based on demand signals
- Separate monitoring and alerting per type
- Resource limits appropriate per workload

Reference: [The Twelve-Factor App - Concurrency](https://12factor.net/concurrency)
