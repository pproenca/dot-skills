---
title: Reuse Async HTTP Clients Across Requests
impact: CRITICAL
impactDescription: prevents 50-200ms per-request TLS handshake overhead
tags: orch, httpx, async-client, connection-pool, reuse
---

## Reuse Async HTTP Clients Across Requests

Creating a new `httpx.AsyncClient` (or `aiohttp.ClientSession`) per request means: new TCP connection, new TLS handshake (~50-200ms for HTTPS), new connection pool, no DNS cache reuse. For an API that fans out to 3 downstreams on every request, this is 150-600ms of avoidable handshake work *per request* — completely separate from the actual recommendation latency.

Create one async client per downstream, store it at module scope (or via Django app config), and reuse it. The client manages connection pooling, keep-alive, and HTTP/2 multiplexing internally. Configure pool limits to match expected concurrency.

**Incorrect (new client per request — handshakes every time):**

```python
async def get_recommendations(user_id: str):
    async with httpx.AsyncClient() as client:  # ❌ new connection pool per call
        response = await client.post(
            "https://personalize.example.com/recommend",
            json={"user_id": user_id},
        )
        return response.json()
# Every call: DNS lookup + TCP handshake + TLS handshake + HTTP request
# At 100 RPS with 3 fan-out: 300 handshakes/second of waste.
```

**Correct (module-level client reused across requests):**

```python
# clients/personalize.py
import httpx
from django.conf import settings

# One client per downstream — lives for the worker's lifetime
_client: httpx.AsyncClient | None = None

def get_client() -> httpx.AsyncClient:
    global _client
    if _client is None:
        _client = httpx.AsyncClient(
            base_url=settings.PERSONALIZE_URL,
            timeout=httpx.Timeout(connect=0.5, read=2.0, write=1.0, pool=0.5),
            limits=httpx.Limits(
                max_connections=50,           # total pool size
                max_keepalive_connections=20, # idle connections kept open
                keepalive_expiry=30.0,         # idle timeout
            ),
            http2=True,  # multiplex when downstream supports it
            headers={"User-Agent": "django-recommender/1.0"},
        )
    return _client

async def get_recommendations(user_id: str) -> list[dict]:
    response = await get_client().post(
        "/recommend",
        json={"user_id": user_id},
    )
    response.raise_for_status()
    return response.json()["items"]
```

**Graceful shutdown (close clients when the worker exits):**

```python
# apps.py — register a Django app-ready signal that wires shutdown
from django.apps import AppConfig
import asyncio, atexit

class RecommenderConfig(AppConfig):
    name = "recommender"

    def ready(self):
        import recommender.clients.personalize as p
        atexit.register(self._close_client, p)

    @staticmethod
    def _close_client(module):
        if module._client is not None:
            try:
                asyncio.run(module._client.aclose())
            except RuntimeError:
                pass  # event loop already closed
```

**Pool sizing rule of thumb:**

| Parameter | Set to |
|-----------|--------|
| `max_connections` | `worker_concurrency × downstreams_per_request + headroom` |
| `max_keepalive_connections` | ~40% of `max_connections` |
| `keepalive_expiry` | 30-60s (long enough to amortize handshakes, short enough to free idle conns) |

**Boto3 equivalent (AWS Personalize via boto3 — also reuse the client):**

```python
import boto3
from botocore.config import Config

# One boto3 client per worker — DON'T create per-request
_personalize = boto3.client(
    "personalize-runtime",
    config=Config(
        max_pool_connections=50,
        retries={"max_attempts": 0},   # we do retry ourselves with jitter
        connect_timeout=0.5,
        read_timeout=2.0,
    ),
)
# Wrap in asyncio.to_thread for use in async views (boto3 is sync)
```

**Why per-request clients are tempting and wrong:** the `async with httpx.AsyncClient()` pattern from the docs is for *scripts and one-shot tools*, not long-running servers. For a Django process serving thousands of requests, the equivalent is "one client per downstream for the process lifetime."

Reference: [httpx — Clients](https://www.python-httpx.org/async/#opening-and-closing-clients) | [boto3 — config](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html)
