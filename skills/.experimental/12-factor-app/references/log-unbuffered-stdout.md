---
title: Write Logs Unbuffered to Stdout for Real-Time Streaming
impact: MEDIUM
impactDescription: enables real-time log viewing, prevents log loss on crash
tags: log, unbuffered, stdout, realtime
---

## Write Logs Unbuffered to Stdout for Real-Time Streaming

Each running process writes its event stream unbuffered to stdout. This ensures logs are visible immediately for real-time debugging and aren't lost if the process crashes before flushing buffers.

**Incorrect (buffered output):**

```python
import sys

# Python buffers stdout by default when not connected to terminal
# Logs may not appear until buffer is full or process exits
print("Starting processing...")
# ... process runs for 10 minutes ...
print("Processing complete")
# If process crashes, both messages might be lost

# File-based logging with buffering
import logging
handler = logging.FileHandler('/var/log/app.log')
handler.setLevel(logging.INFO)
# Default mode is buffered - logs written in chunks
```

**Correct (unbuffered stdout):**

```python
import sys
import logging

# Force unbuffered stdout
# Option 1: Environment variable
# PYTHONUNBUFFERED=1

# Option 2: In code
sys.stdout.reconfigure(line_buffering=True)
# Or for full unbuffering:
sys.stdout = sys.stderr = open(sys.stdout.fileno(), 'w', buffering=1)

# Configure logging with stream handler
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

logger = logging.getLogger(__name__)

# Each log appears immediately
logger.info("Starting processing...")  # Visible immediately
# ... process runs ...
logger.info("Processing complete")     # Visible immediately
```

**Dockerfile configuration:**

```dockerfile
FROM python:3.11

# Ensure unbuffered output
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY . .

CMD ["python", "app.py"]
# All print() and logging output is immediately visible
# docker logs -f container_name shows real-time output
```

**Node.js unbuffered:**

```javascript
// Node.js stdout is unbuffered by default
// But console.log adds newlines, which helps

// For explicit control:
process.stdout.write('Processing...\n');

// Ensure flush on exit
process.on('exit', () => {
    process.stdout.write('');  // Flush
});
```

**Why unbuffered matters:**

```bash
# Real-time debugging
kubectl logs -f deployment/web
# See each log line as it happens

# Crash investigation
# Process crashed - last logs are visible because unbuffered
# With buffering, last 4KB might be lost

# Streaming to log aggregator
# Fluentd/Logstash receives events immediately
# Alerting can trigger in real-time
```

**Benefits:**
- `docker logs -f` and `kubectl logs -f` show real-time output
- No log loss on crash
- Real-time alerting possible
- Debugging live issues is straightforward

Reference: [The Twelve-Factor App - Logs](https://12factor.net/logs)
