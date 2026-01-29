---
title: Never Daemonize or Write PID Files Let Process Manager Handle It
impact: HIGH
impactDescription: enables process manager control, proper signal handling, crash recovery
tags: scale, daemon, process-manager, signals
---

## Never Daemonize or Write PID Files Let Process Manager Handle It

Twelve-factor app processes should never daemonize (fork and detach from terminal) or write PID files. Instead, rely on the operating system's process manager (systemd, Kubernetes, Docker, Heroku) to manage output streams, handle crashes, and control process lifecycle.

**Incorrect (self-daemonizing):**

```python
import os
import sys

def daemonize():
    # Double-fork to detach from terminal
    if os.fork() > 0:
        sys.exit(0)
    os.setsid()
    if os.fork() > 0:
        sys.exit(0)

    # Write PID file
    with open('/var/run/myapp.pid', 'w') as f:
        f.write(str(os.getpid()))

    # Redirect stdout/stderr to files
    sys.stdout = open('/var/log/myapp.log', 'a')
    sys.stderr = open('/var/log/myapp.error', 'a')

    # Now run the app
    run_app()

# Problems:
# - Process manager can't track the process
# - Logs go to files, not captured by platform
# - PID file becomes stale on crash
# - Can't send signals properly
```

**Correct (foreground process):**

```python
import logging
import sys

# Log to stdout/stderr - platform captures it
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

def main():
    logging.info("Starting application")
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
    # Runs in foreground
    # stdout/stderr captured by process manager
    # No PID file needed

if __name__ == '__main__':
    main()
```

**Process manager handles lifecycle:**

```ini
# systemd unit file
[Unit]
Description=My Application

[Service]
Type=simple  # Not forking - process stays in foreground
ExecStart=/usr/bin/python /app/main.py
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```yaml
# Kubernetes - container runs in foreground
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    command: ["python", "main.py"]
    # Kubernetes monitors the process
    # Restarts on crash
    # Captures stdout/stderr as logs
```

```dockerfile
# Docker - CMD runs in foreground
FROM python:3.11
WORKDIR /app
COPY . .
CMD ["python", "main.py"]
# Docker monitors the process
# 'docker logs' shows stdout/stderr
```

**Benefits:**
- Process manager can restart crashed processes
- Logs captured and routed by platform
- Clean shutdown via SIGTERM
- Resource limits enforced properly

Reference: [The Twelve-Factor App - Concurrency](https://12factor.net/concurrency)
