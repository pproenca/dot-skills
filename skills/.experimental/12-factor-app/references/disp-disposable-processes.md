---
title: Design Processes to Be Disposable Started or Stopped at Any Moment
impact: HIGH
impactDescription: enables rapid deployment, elastic scaling, and fault tolerance
tags: disp, disposability, lifecycle, resilience
---

## Design Processes to Be Disposable Started or Stopped at Any Moment

Twelve-factor app processes are disposable - they can be started or stopped at a moment's notice. This supports fast elastic scaling, rapid deployment of code or config changes, and robustness of production deploys.

**Incorrect (processes that can't be stopped):**

```python
# Process assumes it will run forever
class LongRunningProcessor:
    def __init__(self):
        self.running = True

    def run(self):
        while self.running:
            # Hours-long batch job
            data = fetch_all_records()  # 1 million records
            for record in data:
                process_record(record)
            # Can't stop mid-batch
            # Scaling down kills in-progress work
            # Deploy must wait for batch to complete
```

**Correct (disposable, interruptible processes):**

```python
import signal
import sys

class DisposableProcessor:
    def __init__(self):
        self.should_stop = False
        # Handle shutdown signals gracefully
        signal.signal(signal.SIGTERM, self._handle_shutdown)
        signal.signal(signal.SIGINT, self._handle_shutdown)

    def _handle_shutdown(self, signum, frame):
        print("Shutdown signal received, finishing current item...")
        self.should_stop = True

    def run(self):
        while not self.should_stop:
            # Process one item at a time
            record = fetch_one_record()
            if record:
                process_record(record)
                mark_complete(record)
            else:
                # No work, check again soon
                time.sleep(1)

        print("Graceful shutdown complete")
        sys.exit(0)

# Can be stopped anytime - at most loses one record
# Which is immediately reprocessed by another worker
```

**Kubernetes graceful shutdown:**

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      terminationGracePeriodSeconds: 30  # Time to finish
      containers:
      - name: app
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 5"]
        # SIGTERM sent, then 30s to finish, then SIGKILL
```

**Benefits:**
- New deployments can start immediately
- Scale down doesn't lose work
- Crashed processes quickly replaced
- Autoscaling responds to demand in seconds

Reference: [The Twelve-Factor App - Disposability](https://12factor.net/disposability)
