---
title: Use Queue for Thread-Safe Communication
impact: HIGH
impactDescription: prevents race conditions
tags: conc, queue, thread-safety, producer-consumer
---

## Use Queue for Thread-Safe Communication

Sharing mutable state between threads causes race conditions. Use `queue.Queue` for thread-safe producer-consumer patterns.

**Incorrect (shared list with race condition):**

```python
import threading

results = []  # Shared mutable state

def worker(items: list[str]) -> None:
    for item in items:
        processed = process_item(item)
        results.append(processed)  # Race condition!

threads = [threading.Thread(target=worker, args=(chunk,)) for chunk in chunks]
for t in threads:
    t.start()
for t in threads:
    t.join()
# results may have corrupted or missing data
```

**Correct (thread-safe queue):**

```python
import threading
from queue import Queue

def worker(input_queue: Queue, output_queue: Queue) -> None:
    while True:
        item = input_queue.get()
        if item is None:  # Poison pill
            break
        output_queue.put(process_item(item))
        input_queue.task_done()

input_queue = Queue()
output_queue = Queue()

threads = [threading.Thread(target=worker, args=(input_queue, output_queue))
           for _ in range(4)]
for t in threads:
    t.start()

for item in items:
    input_queue.put(item)

input_queue.join()  # Wait for all items processed

for _ in threads:
    input_queue.put(None)  # Signal workers to stop
for t in threads:
    t.join()

results = [output_queue.get() for _ in range(len(items))]
```

**Note:** For async code, use `asyncio.Queue` instead.

Reference: [queue documentation](https://docs.python.org/3/library/queue.html)
