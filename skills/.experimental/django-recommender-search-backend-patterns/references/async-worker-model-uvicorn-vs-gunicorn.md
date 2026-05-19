---
title: Run Async Views Under Uvicorn or Gunicorn+UvicornWorker
impact: MEDIUM-HIGH
impactDescription: enables true async concurrency per worker
tags: async, uvicorn, gunicorn, asgi, deployment
---

## Run Async Views Under Uvicorn or Gunicorn+UvicornWorker

Async views give the speedup only when the server runs an ASGI event loop. The default Django setup with `gunicorn myapp.wsgi:application` runs WSGI — synchronous, with one request per worker thread at a time. Async views work, but `asyncio.gather` doesn't parallelize across requests; one slow downstream still blocks the worker for the next request.

Switch to ASGI: `uvicorn myapp.asgi:application` (single-process, multi-loop) or `gunicorn -k uvicorn.workers.UvicornWorker myapp.asgi:application` (multi-process supervised by gunicorn, each running a uvicorn loop). With ASGI, one worker handles hundreds of concurrent in-flight requests during their async-await waits.

**Incorrect (WSGI + async views — no concurrency benefit):**

```bash
# Production deployment
gunicorn myapp.wsgi:application --workers 4 --threads 8
# Each worker thread serializes requests. Async views work but
# asyncio.gather doesn't help with cross-request concurrency.
```

```python
# settings/wsgi.py — wrong target for an async app
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
```

**Correct (ASGI deployment with uvicorn workers):**

```bash
# settings/asgi.py
from django.core.asgi import get_asgi_application
application = get_asgi_application()
```

```bash
# Production deployment — gunicorn supervises N uvicorn workers
gunicorn myapp.asgi:application \
  -k uvicorn.workers.UvicornWorker \
  --workers 4 \
  --bind 0.0.0.0:8000 \
  --timeout 30 \
  --graceful-timeout 30 \
  --max-requests 5000 \
  --max-requests-jitter 500

# Each of the 4 workers runs an asyncio event loop.
# Each can handle hundreds of concurrent in-flight requests.
```

**Worker count formula:**

| Workload | Workers |
|----------|---------|
| Pure async (IO-bound, all async) | `2 × cpu_count` is overkill; `cpu_count` is plenty |
| Mixed sync/async (some sync_to_async) | `2 × cpu_count` |
| Heavy sync (many sync_to_async + ORM) | `(2 × cpu_count) + 1` (Gunicorn default) |

Async workloads don't need many workers — the gain comes from in-process concurrency, not worker count. Adding workers consumes more memory without proportional throughput.

**Set `--max-requests` to recycle workers (memory hygiene):**

```bash
--max-requests 5000 --max-requests-jitter 500
# Each worker handles 4500-5500 requests then exits and respawns.
# Prevents long-term memory growth and reclaims any leaked memory.
```

**Configure uvicorn loop settings:**

```bash
# Use uvloop (faster event loop) if available — drop-in replacement
pip install uvloop httptools

# uvicorn auto-detects and uses uvloop
gunicorn myapp.asgi:application \
  -k uvicorn.workers.UvicornWorker \
  --workers 4 \
  --worker-tmp-dir /dev/shm \
  --keep-alive 5
```

**Local development:**

```bash
# Single-process uvicorn with auto-reload
uvicorn myapp.asgi:application --reload --port 8000

# Or use Django's runserver which detects async views automatically:
python manage.py runserver
```

**Daphne is an alternative to uvicorn:**

```bash
daphne -b 0.0.0.0 -p 8000 myapp.asgi:application
```

Daphne is feature-complete for Channels (websockets). For pure HTTP async, uvicorn is slightly faster and more popular.

**Sync views still work under ASGI:**

ASGI servers handle sync views by running them in a thread pool. The trade-off: with many sync views, the thread pool becomes the bottleneck. For mostly-sync codebases, WSGI may be simpler. For codebases with significant async fan-out, ASGI wins.

**Mixed-deploy patterns:**

| Pattern | When |
|---------|------|
| All ASGI, all async views | New project, async-first |
| All ASGI, mixed sync + async | Common — migrate views gradually |
| Two services: WSGI for sync, ASGI for async | Microservice separation; complex but isolates risk |
| All WSGI | If no async views and no near-term plans |

**Configure ASGI middleware (channels middleware is async-aware):**

```python
# settings.py
# Django middleware works for both — the framework adapts via sync/async detection
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    # ... your middleware
]

# For middleware you write — implement __call__ as async if your middleware does async IO
class AsyncMiddleware:
    async_capable = True
    sync_capable = False

    def __init__(self, get_response):
        self.get_response = get_response

    async def __call__(self, request):
        # async middleware logic
        response = await self.get_response(request)
        return response
```

**Symptom of wrong server choice:**
- "Async views but throughput same as sync" — running WSGI
- High latency under load even with sparse traffic — single-threaded worker pool
- `asyncio.gather` doesn't speed up requests — proves the loop isn't running

**Diagnose what's running:**

```python
import asyncio
import logging

logger = logging.getLogger(__name__)

async def my_view(request):
    loop = asyncio.get_running_loop()
    logger.info("loop_running", policy=type(asyncio.get_event_loop_policy()).__name__,
                impl=type(loop).__name__)
    # If you see "DefaultEventLoopPolicy" and "BaseEventLoop", you're on default asyncio.
    # If you see "UVLoopPolicy" and "Loop", you're on uvloop (faster).
    # If this code throws "no running event loop", you're on WSGI — async isn't active.
```

Reference: [Django — Deployment with ASGI](https://docs.djangoproject.com/en/5.0/howto/deployment/asgi/) | [Uvicorn](https://www.uvicorn.org/) | [Gunicorn UvicornWorker](https://www.uvicorn.org/deployment/#gunicorn)
