---
title: Use exec in Entrypoint Scripts
impact: MEDIUM
impactDescription: eliminates 10-second forced kill delay on every container stop
tags: inst, entrypoint, exec, signals, pid1
---

## Use exec in Entrypoint Scripts

When a shell entrypoint script launches the application without `exec`, the shell remains as PID 1 and the application runs as a child process. The shell does not forward OS signals (SIGTERM, SIGINT) to its children by default, so the application never receives the stop signal. Docker waits for the grace period (default 10 seconds) then forcibly kills the entire process tree with SIGKILL, preventing graceful shutdown, connection draining, and cleanup operations.

**Incorrect (no exec -- shell remains PID 1, application cannot receive signals):**

```bash
#!/bin/bash
# docker-entrypoint.sh
setup_database
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

(The shell script is PID 1. When Docker sends SIGTERM to stop the container, bash receives the signal but does not forward it to the python child process. The python server continues running until Docker sends SIGKILL after the timeout, abruptly terminating in-flight requests and database transactions.)

**Correct (exec replaces the shell with the application as PID 1):**

```bash
#!/bin/bash
# docker-entrypoint.sh
set -e
setup_database
python manage.py migrate
exec python manage.py runserver 0.0.0.0:8000
```

(The `exec` builtin replaces the shell process with python, making python PID 1. SIGTERM is delivered directly to the application, which can close database connections, finish in-flight requests, and exit cleanly.)

**Correct (exec "$@" pattern -- entrypoint delegates to CMD arguments):**

```bash
#!/bin/bash
# docker-entrypoint.sh
set -e

# Run initialization tasks
if [ "$1" = 'postgres' ]; then
    # Initialize data directory if needed
    if [ -z "$(ls -A "$PGDATA")" ]; then
        initdb --username="$POSTGRES_USER" --pwfile=<(echo "$POSTGRES_PASSWORD")
    fi
fi

# Replace shell with the CMD arguments
exec "$@"
```

(The `exec "$@"` pattern passes all CMD arguments through to `exec`, making the CMD process PID 1. This is the pattern used by official Docker images like PostgreSQL, Redis, and MySQL. It allows the Dockerfile to define the default command while the entrypoint handles initialization.)

**Dockerfile using the exec "$@" pattern:**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:8000", "--workers", "4"]
```

(ENTRYPOINT uses exec form to run the script directly without a wrapping shell. CMD provides default arguments that `exec "$@"` in the entrypoint script will use. Running `docker run myimage celery worker` overrides CMD, and the entrypoint script runs initialization before `exec celery worker`.)

### Process Tree Comparison

**Without exec:**
```text
PID 1: /bin/bash /docker-entrypoint.sh
  PID 2: python manage.py runserver 0.0.0.0:8000
```
SIGTERM goes to PID 1 (bash). Python never receives it.

**With exec:**
```text
PID 1: python manage.py runserver 0.0.0.0:8000
```
SIGTERM goes directly to python. Bash is gone.

### Guidelines

- Always use `set -e` at the top of entrypoint scripts so initialization failures abort the container start instead of silently continuing.
- Place `exec` on the **last line** of the entrypoint script. Any commands after `exec` will never run because `exec` replaces the current process.
- Use `exec "$@"` rather than hardcoding the application command in the entrypoint. This preserves the separation between initialization (ENTRYPOINT) and the default command (CMD).
- Use ENTRYPOINT in **exec form** (`ENTRYPOINT ["/docker-entrypoint.sh"]`) in the Dockerfile. Shell form (`ENTRYPOINT /docker-entrypoint.sh`) wraps the script in `/bin/sh -c`, adding yet another shell layer.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
