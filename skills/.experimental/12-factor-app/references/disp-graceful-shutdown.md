---
title: Implement Graceful Shutdown on SIGTERM
impact: HIGH
impactDescription: prevents request failures during deploys, ensures data integrity
tags: disp, shutdown, signals, graceful
---

## Implement Graceful Shutdown on SIGTERM

When a process receives SIGTERM, it should stop accepting new work, finish in-flight requests, then exit cleanly. This enables zero-downtime deployments and prevents data loss during scaling operations.

**Incorrect (abrupt termination):**

```python
# No signal handling - killed immediately
from flask import Flask
app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process():
    # 30-second operation
    data = request.json
    result = expensive_operation(data)  # Halfway through...
    save_result(result)  # SIGKILL - never saved!
    return {'result': result}

# On SIGTERM: process killed mid-request
# Client gets connection reset
# Data potentially corrupted
```

**Correct (graceful shutdown):**

```python
import signal
import sys
from flask import Flask
from werkzeug.serving import make_server

app = Flask(__name__)
server = None

@app.route('/process', methods=['POST'])
def process():
    data = request.json
    result = expensive_operation(data)
    save_result(result)
    return {'result': result}

def handle_sigterm(signum, frame):
    print("SIGTERM received, shutting down gracefully...")
    if server:
        server.shutdown()  # Stop accepting new connections

# Register signal handler
signal.signal(signal.SIGTERM, handle_sigterm)

if __name__ == '__main__':
    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()
    # After shutdown(), in-flight requests complete
    # Then process exits cleanly
```

**Production WSGI server with graceful shutdown:**

```python
# gunicorn.conf.py
graceful_timeout = 30  # Seconds to wait for workers to finish
timeout = 30  # Request timeout

def on_exit(server):
    print("Gunicorn shutting down gracefully")

def worker_exit(server, worker):
    print(f"Worker {worker.pid} exiting")
```

```bash
# Start with config
gunicorn app:app -c gunicorn.conf.py

# On SIGTERM:
# 1. Stop accepting new connections
# 2. Wait up to graceful_timeout for in-flight requests
# 3. Exit cleanly
```

**Worker graceful shutdown:**

```python
from celery import Celery
from celery.signals import worker_shutting_down

app = Celery('tasks')

@worker_shutting_down.connect
def handle_shutdown(sig, how, exitcode, **kwargs):
    print("Worker shutting down, completing current task...")
    # Current task will complete
    # No new tasks accepted

@app.task(acks_late=True)  # Acknowledge after completion
def process_job(data):
    result = expensive_operation(data)
    save_result(result)
    return result
    # If killed before completion, job returns to queue
```

**Benefits:**
- Zero-downtime deployments
- No dropped requests during scaling
- Data integrity preserved
- Clean resource cleanup (connections, file handles)

Reference: [The Twelve-Factor App - Disposability](https://12factor.net/disposability)
