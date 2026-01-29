---
title: Design for Crash-Only Software That Recovers from Sudden Death
impact: HIGH
impactDescription: ensures resilience to hardware failures, prevents data loss
tags: disp, crash-only, resilience, recovery
---

## Design for Crash-Only Software That Recovers from Sudden Death

Even with graceful shutdown, processes can die suddenly (hardware failure, OOM killer, network partition). Design your application to recover cleanly from abrupt termination without data loss or corruption.

**Incorrect (assumes clean shutdown):**

```python
class JobProcessor:
    def process_job(self, job):
        # Mark job as "in progress" in database
        db.execute("UPDATE jobs SET status='processing' WHERE id=?", job.id)

        # Do the work
        result = expensive_computation(job.data)

        # Save result and mark complete
        save_result(result)
        db.execute("UPDATE jobs SET status='complete' WHERE id=?", job.id)

# If process dies after marking "processing" but before "complete":
# Job stuck in "processing" forever
# Other workers won't pick it up
# Manual intervention required
```

**Correct (crash-safe design):**

```python
class JobProcessor:
    def process_job(self, job):
        # Idempotent processing with timeout
        # Other workers can retry if we die
        lock = redis.lock(f'job:{job.id}', timeout=300)  # 5 min max

        if not lock.acquire(blocking=False):
            return  # Another worker has it

        try:
            # Check if already completed (idempotency)
            if db.query("SELECT status FROM jobs WHERE id=?", job.id) == 'complete':
                return

            result = expensive_computation(job.data)

            # Atomic transaction: save result AND mark complete
            with db.transaction():
                save_result(result)
                db.execute("UPDATE jobs SET status='complete' WHERE id=?", job.id)

        finally:
            lock.release()

# If process dies:
# - Lock expires after 5 minutes
# - Another worker picks up the job
# - Idempotency check prevents duplicate processing
```

**Queue-based crash safety:**

```python
from celery import Celery

app = Celery('tasks')
app.conf.task_acks_late = True  # Acknowledge AFTER completion
app.conf.task_reject_on_worker_lost = True  # Requeue if worker dies

@app.task(bind=True, max_retries=3)
def process_job(self, job_id):
    try:
        job = get_job(job_id)
        result = process(job)
        save_result(result)
    except Exception as e:
        # On any failure, task returns to queue
        raise self.retry(exc=e, countdown=60)
    # Only acknowledged after successful return
    # Worker death = task returned to queue automatically
```

**Database transaction safety:**

```python
# Use transactions for multi-step operations
def transfer_funds(from_account, to_account, amount):
    with db.transaction():
        db.execute("UPDATE accounts SET balance = balance - ? WHERE id = ?",
                   amount, from_account)
        db.execute("UPDATE accounts SET balance = balance + ? WHERE id = ?",
                   amount, to_account)
    # Either both succeed or both fail
    # Crash mid-transaction = automatic rollback
```

**Benefits:**
- Hardware failures don't lose data
- Automatic recovery without manual intervention
- Simpler operations - just restart everything
- Confidence in rapid deployment and scaling

Reference: [The Twelve-Factor App - Disposability](https://12factor.net/disposability)
