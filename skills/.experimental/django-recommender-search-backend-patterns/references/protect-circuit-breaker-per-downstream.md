---
title: Run One Circuit Breaker per Downstream
impact: CRITICAL
impactDescription: prevents one degraded downstream from cascading
tags: protect, circuit-breaker, downstream, isolation, resilience
---

## Run One Circuit Breaker per Downstream

A single circuit breaker shared across all downstreams is wrong: when Databricks goes down and trips the breaker, Personalize and OpenSearch calls also fail-fast even though they're healthy. The breaker must track *each downstream independently* so a Databricks outage doesn't take down recommendations from Personalize.

Three states: **closed** (calls pass through), **open** (calls reject instantly), **half-open** (one trial call after cooldown — if it succeeds, close). Each downstream gets its own state machine.

**Incorrect (global breaker — one outage trips everything):**

```python
_breaker = CircuitBreaker(threshold=5, cooldown=30)

async def call_personalize(user_id):
    return await _breaker.run(personalize_client.get, user_id)

async def call_databricks(user_id):
    return await _breaker.run(databricks_client.invoke, user_id)
# ❌ Databricks fails 5 times → breaker opens → Personalize also fails fast
```

**Correct (one breaker per downstream):**

```python
from dataclasses import dataclass, field
import asyncio
import time
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half-open"

@dataclass
class CircuitBreaker:
    failure_threshold: int = 5
    cooldown_s: float = 30.0
    state: CircuitState = CircuitState.CLOSED
    failures: int = 0
    opened_at: float = 0.0
    _lock: asyncio.Lock = field(default_factory=asyncio.Lock)

    async def call(self, fn, *args, **kwargs):
        async with self._lock:
            if self.state == CircuitState.OPEN:
                if time.monotonic() - self.opened_at < self.cooldown_s:
                    raise CircuitOpenError("circuit open")
                self.state = CircuitState.HALF_OPEN  # allow one trial

        try:
            result = await fn(*args, **kwargs)
        except Exception:
            async with self._lock:
                self.failures += 1
                if self.state == CircuitState.HALF_OPEN or self.failures >= self.failure_threshold:
                    self.state = CircuitState.OPEN
                    self.opened_at = time.monotonic()
                    logger.warning("circuit_opened", downstream=self.name, failures=self.failures)
            raise

        async with self._lock:
            self.failures = 0
            self.state = CircuitState.CLOSED
        return result

class CircuitOpenError(Exception):
    pass

# One breaker per downstream — kept at module scope
PERSONALIZE_BREAKER = CircuitBreaker(failure_threshold=5, cooldown_s=30.0)
AFFINITY_BREAKER    = CircuitBreaker(failure_threshold=10, cooldown_s=15.0)
DATABRICKS_BREAKER  = CircuitBreaker(failure_threshold=3,  cooldown_s=60.0)  # less tolerant — slow recovery
OPENSEARCH_BREAKER  = CircuitBreaker(failure_threshold=10, cooldown_s=10.0)
```

**Wire breakers into clients:**

```python
async def get_personalize_recommendations(user_id: str):
    return await PERSONALIZE_BREAKER.call(personalize_client.get, user_id)
```

**Tune breakers per downstream characteristics:**

| Downstream | Threshold | Cooldown | Rationale |
|------------|-----------|----------|-----------|
| Personalize (AWS) | 5 | 30s | Stable service, fast recovery; can be intolerant |
| Affinity microservice | 10 | 15s | Internal — flakier under deploys, recovers fast |
| Databricks Model Serving | 3 | 60s | Expensive cold-starts; don't hammer during recovery |
| OpenSearch | 10 | 10s | Shard-level failures are common; recoverable quickly |

**On open: render the partial-results path:**

```python
async def get_recommendations(user_id: str):
    results = await asyncio.gather(
        _try(PERSONALIZE_BREAKER.call(personalize_client.get, user_id)),
        _try(AFFINITY_BREAKER.call(affinity_client.get, user_id)),
        _try(DATABRICKS_BREAKER.call(databricks_client.invoke, user_id)),
        return_exceptions=True,
    )
    return blend_partial(results, breakers_open=[
        name for name, b in BREAKERS.items() if b.state == CircuitState.OPEN
    ])
```

**Production-grade alternative — pybreaker:** if you want richer features (event listeners, breaker storage backends, half-open tries count), use the `pybreaker` library. The example above is intentionally minimal to show the state machine.

**Pair with [[resilience-partial-response-envelope]]:** when a breaker is open, surface that in the response (`partial: true, failed_sources: ["databricks"]`) so callers know not to cache the result as full.

Reference: [Netflix Hystrix — Circuit Breaker](https://github.com/Netflix/Hystrix/wiki/How-it-Works) | [pybreaker](https://github.com/danielfm/pybreaker)
