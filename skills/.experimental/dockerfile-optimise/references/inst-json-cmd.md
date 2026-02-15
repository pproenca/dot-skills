---
title: Use JSON Form for CMD and ENTRYPOINT
impact: MEDIUM
impactDescription: eliminates 10-second forced kill timeout on every container stop
tags: inst, cmd, entrypoint, exec-form, signals
---

## Use JSON Form for CMD and ENTRYPOINT

Shell form (`CMD command arg1`) wraps the process in `/bin/sh -c`, which means the shell becomes PID 1 instead of your application. The shell does not forward OS signals (SIGTERM, SIGINT) to the child process, so the application cannot shut down gracefully. In orchestrated environments like Kubernetes or Docker Swarm, this results in a 10-second forced kill timeout on every deploy, restart, or scale-down event.

**Incorrect (shell form -- shell is PID 1, application does not receive signals):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000
CMD node server.js
```

(The `CMD node server.js` instruction is interpreted as `CMD ["/bin/sh", "-c", "node server.js"]`. The shell becomes PID 1 and node runs as a child process. When Docker sends SIGTERM to stop the container, the shell receives it but does not forward it to node. After a 10-second grace period, Docker sends SIGKILL, forcibly terminating the process without cleanup.)

**Correct (JSON/exec form -- application is PID 1, receives signals directly):**

```dockerfile
FROM node:22-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

(The `CMD ["node", "server.js"]` instruction runs node directly as PID 1 with no intermediate shell. SIGTERM is delivered to the node process, allowing it to close database connections, flush logs, and finish in-flight requests before exiting.)

**Correct (ENTRYPOINT in exec form for Python applications):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

EXPOSE 8000
ENTRYPOINT ["python", "-m", "uvicorn"]
CMD ["main:app", "--host", "0.0.0.0", "--port", "8000"]
```

(Both ENTRYPOINT and CMD use exec form. The ENTRYPOINT defines the executable and CMD provides default arguments. Running `docker run myimage --workers 4` replaces CMD but keeps the ENTRYPOINT, resulting in `python -m uvicorn --workers 4`.)

### Shell Form vs Exec Form Reference

| Instruction | Shell Form | Exec Form |
|-------------|-----------|-----------|
| CMD | `CMD node server.js` | `CMD ["node", "server.js"]` |
| ENTRYPOINT | `ENTRYPOINT python app.py` | `ENTRYPOINT ["python", "app.py"]` |
| PID 1 | `/bin/sh -c` | Your application |
| Signal forwarding | No | Yes |
| Variable expansion | Yes (`$HOME`) | No (use shell explicitly if needed) |

### When Shell Form is Acceptable

Shell form is needed when the command relies on shell features like variable expansion, pipes, or redirection. In that case, combine it with `exec` to ensure proper signal handling:

```dockerfile
CMD ["sh", "-c", "exec java $JAVA_OPTS -jar /app/server.jar"]
```

(The `exec` replaces the shell with the java process, restoring proper PID 1 signal handling while retaining shell variable expansion.)

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
