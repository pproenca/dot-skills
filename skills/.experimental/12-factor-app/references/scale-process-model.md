---
title: Scale Out via the Process Model with Multiple Process Types
impact: HIGH
impactDescription: enables horizontal scaling, matches workload diversity to process types
tags: scale, processes, horizontal-scaling, concurrency
---

## Scale Out via the Process Model with Multiple Process Types

A twelve-factor app scales out by running multiple processes. Different types of work (web requests, background jobs, scheduled tasks) are assigned to different process types. Scaling means increasing the number of processes of each type as needed.

**Incorrect (single monolithic process):**

```python
# Single process doing everything
from threading import Thread
from flask import Flask

app = Flask(__name__)

@app.route('/api/data')
def api_endpoint():
    return {"data": "value"}

def background_worker():
    while True:
        # Process background jobs in same process
        job = get_next_job()
        process_job(job)

def scheduled_task():
    while True:
        # Run scheduled tasks in same process
        time.sleep(60)
        cleanup_old_data()

# All in one process - can't scale independently
Thread(target=background_worker).start()
Thread(target=scheduled_task).start()
app.run()
# Web traffic spike? Can't add web capacity without adding workers
# Worker backlog? Can't add workers without adding web servers
```

**Correct (separate process types):**

```yaml
# Procfile - defines process types
web: gunicorn app:application --workers 4
worker: celery -A tasks worker --concurrency 10
scheduler: celery -A tasks beat
```

```python
# web.py - handles HTTP requests only
from flask import Flask
app = Flask(__name__)

@app.route('/api/data')
def api_endpoint():
    # Enqueue work instead of doing it inline
    process_data.delay(request.json)
    return {"status": "queued"}
```

```python
# tasks.py - background workers only
from celery import Celery
app = Celery('tasks', broker=os.environ['REDIS_URL'])

@app.task
def process_data(data):
    # Worker processes these asynchronously
    result = expensive_computation(data)
    save_result(result)

@app.task
def cleanup_old_data():
    # Scheduled task runs periodically
    delete_records_older_than(days=30)
```

**Scaling independently:**

```bash
# Scale web processes for traffic spike
heroku ps:scale web=10

# Scale workers for job backlog
heroku ps:scale worker=20

# Or in Kubernetes
kubectl scale deployment web --replicas=10
kubectl scale deployment worker --replicas=20
```

**Benefits:**
- Scale each workload type independently
- Resource allocation matches actual demand
- Failure isolation: crashed worker doesn't affect web
- Clear separation of concerns

Reference: [The Twelve-Factor App - Concurrency](https://12factor.net/concurrency)
