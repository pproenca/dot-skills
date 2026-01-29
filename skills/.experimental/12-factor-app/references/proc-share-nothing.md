---
title: Design Processes to Share Nothing with Each Other
impact: HIGH
impactDescription: enables independent scaling, prevents cascade failures
tags: proc, share-nothing, isolation, scaling
---

## Design Processes to Share Nothing with Each Other

Each process in a twelve-factor app operates independently. Processes don't share memory, filesystem, or communicate directly. All coordination happens through backing services. This share-nothing architecture enables reliable horizontal scaling.

**Incorrect (processes sharing resources):**

```python
# Shared memory via mmap or shared dict
from multiprocessing import Manager

manager = Manager()
shared_cache = manager.dict()  # Shared between worker processes

def handle_request(item_id):
    if item_id in shared_cache:
        return shared_cache[item_id]
    # If workers are on different machines, this doesn't work
    # Shared memory only works within single host

# Inter-process communication via filesystem
def acquire_lock(resource):
    lock_file = f'/var/locks/{resource}.lock'
    # Only works if all processes see same filesystem
    # Kubernetes pods have isolated filesystems

# Direct inter-process messaging
import socket
def notify_other_worker(message):
    sock = socket.socket()
    sock.connect(('worker-2', 9999))  # Assumes static topology
    sock.send(message)
    # What if worker-2 doesn't exist? Wrong IP? Scales dynamically?
```

**Correct (coordinate via backing services):**

```python
import redis
import os

redis_client = redis.from_url(os.environ['REDIS_URL'])

# Cache via Redis (shared backing service)
def handle_request(item_id):
    cached = redis_client.get(f'item:{item_id}')
    if cached:
        return json.loads(cached)
    # Compute and cache
    result = expensive_computation(item_id)
    redis_client.setex(f'item:{item_id}', 3600, json.dumps(result))
    return result

# Distributed locking via Redis
def acquire_lock(resource, timeout=10):
    lock = redis_client.lock(f'lock:{resource}', timeout=timeout)
    return lock.acquire(blocking=True, blocking_timeout=5)

# Message passing via queue
import pika
def notify_workers(message):
    connection = pika.BlockingConnection(
        pika.URLParameters(os.environ['RABBITMQ_URL'])
    )
    channel = connection.channel()
    channel.queue_declare(queue='notifications')
    channel.basic_publish(exchange='', routing_key='notifications', body=message)
    connection.close()
    # Any worker subscribed to queue receives message
    # Works regardless of number of workers or their locations
```

**Benefits:**
- Add/remove processes without coordination
- Process crashes don't affect other processes
- Geographic distribution becomes possible
- No single point of failure from shared resource

Reference: [The Twelve-Factor App - Processes](https://12factor.net/processes)
