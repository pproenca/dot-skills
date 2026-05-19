---
title: Tag Every Downstream Call with Structured Source Metadata
impact: HIGH
impactDescription: prevents silent degradation in production
tags: resilience, observability, metrics, tags, downstream
---

## Tag Every Downstream Call with Structured Source Metadata

When recommendations look weird in production, the question is always: *which source returned bad data?* Without per-source tagging on logs and metrics, the answer is "unknown" — you'd have to read raw response bodies (if you logged them) and correlate by timestamp. With per-source tags, dashboards show Personalize latency vs Databricks latency vs OpenSearch latency *separately*, and a degradation in one immediately stands out.

Tag every external call with `source` (Personalize/affinity/databricks/opensearch), `outcome` (ok/error/timeout/circuit_open), and where available `model_version` and `endpoint`. Apply uniformly across logs, metrics, and traces.

**Incorrect (no tags — degraded path invisible):**

```python
async def get_recommendations(user_id: str):
    results = await asyncio.gather(
        personalize_client.get(user_id),
        affinity_client.get(user_id),
        databricks_client.invoke(user_id),
        return_exceptions=True,
    )
    duration_ms = ...
    metrics.histogram("recommendations.latency", duration_ms)
    metrics.increment("recommendations.called")
    # ❌ Can't tell which source took how long, which one errored
```

**Correct (per-source tagged metrics):**

```python
import time
import structlog

logger = structlog.get_logger()

async def call_with_observability(name: str, fn, user_id: str):
    """Wrap any downstream call to emit structured metrics + logs."""
    start = time.monotonic()
    outcome = "ok"
    err_class = None

    try:
        result = await fn()
        return result
    except CircuitOpenError:
        outcome = "circuit_open"
        raise
    except asyncio.TimeoutError:
        outcome = "timeout"
        raise
    except Exception as e:
        outcome = "error"
        err_class = type(e).__name__
        raise
    finally:
        duration_ms = (time.monotonic() - start) * 1000
        tags = {"source": name, "outcome": outcome}
        if err_class:
            tags["error_class"] = err_class

        metrics.histogram("downstream.latency_ms", duration_ms, tags=tags)
        metrics.increment("downstream.calls", tags=tags)
        logger.info(
            "downstream_call",
            source=name,
            outcome=outcome,
            duration_ms=int(duration_ms),
            user_id=user_id,
            err_class=err_class,
        )

# Usage at the call site:
async def get_recommendations(user_id: str):
    results = await asyncio.gather(
        call_with_observability("personalize", lambda: personalize_client.get(user_id), user_id),
        call_with_observability("affinity", lambda: affinity_client.get(user_id), user_id),
        call_with_observability("databricks", lambda: databricks_client.invoke(user_id), user_id),
        return_exceptions=True,
    )
```

**Dashboards that show what's degraded:**

| Dashboard panel | Query (Datadog/Prometheus syntax) |
|------------------|------------------------------------|
| Per-source p99 latency | `histogram_quantile(0.99, sum by (source) (rate(downstream_latency_ms_bucket[5m])))` |
| Per-source error rate | `sum by (source) (rate(downstream_calls_total{outcome="error"}[5m])) / sum by (source) (rate(downstream_calls_total[5m]))` |
| Circuit-breaker state | `sum by (source) (downstream_calls_total{outcome="circuit_open"})` |
| Outcome breakdown stacked | `sum by (source, outcome) (rate(downstream_calls_total[5m]))` |

The eye scans these and immediately identifies the laggard: one source's bar is taller / one source's outcome=error is non-zero.

**Tag distributed traces too:**

```python
from opentelemetry import trace
tracer = trace.get_tracer(__name__)

async def call_with_observability(name: str, fn, user_id: str):
    with tracer.start_as_current_span(f"downstream.{name}") as span:
        span.set_attribute("downstream.source", name)
        span.set_attribute("user.id", user_id)
        try:
            result = await fn()
            span.set_attribute("downstream.outcome", "ok")
            return result
        except Exception as e:
            span.set_attribute("downstream.outcome", "error")
            span.set_attribute("downstream.error_class", type(e).__name__)
            span.record_exception(e)
            raise
```

In Jaeger/Tempo/Datadog APM, the trace timeline visually shows which downstream took the longest, with consistent tags so search ("show me all traces where source=databricks and outcome=error") works.

**Standardize tag names across the codebase:**

```python
# Centralize as constants — typo-resistant, refactor-safe
class SourceTags:
    PERSONALIZE = "personalize"
    AFFINITY    = "affinity"
    DATABRICKS  = "databricks"
    OPENSEARCH  = "opensearch"
    REDIS_CACHE = "redis_cache"
    FALLBACK    = "fallback"

class OutcomeTags:
    OK            = "ok"
    ERROR         = "error"
    TIMEOUT       = "timeout"
    CIRCUIT_OPEN  = "circuit_open"
    RATE_LIMITED  = "rate_limited"
    CACHED        = "cached"
    STALE         = "stale"
```

**Add tags that aren't just "what" but also "context":**

```python
metrics.increment("downstream.calls", tags={
    "source": "personalize",
    "outcome": "ok",
    "model_version": settings.PERSONALIZE_VERSION,
    "user_segment": user.segment,           # see if errors cluster by segment
    "cold_start": str(user.interaction_count < 5),
})
# Now you can ask: "did the latency spike correlate with the new model version?"
```

**Don't tag with high-cardinality values (kills metrics systems):**

| Safe to tag | Avoid tagging |
|-------------|---------------|
| source name (small enum) | user_id (millions of values) |
| outcome (small enum) | request URL (unbounded) |
| model_version (small enum, ~10) | error message text |
| segment (50-200 values) | timestamp |
| HTTP status code (~10 distinct) | full query string |

High-cardinality tags inflate metric storage cost dramatically. Use logs for high-cardinality detail, metrics for low-cardinality aggregates.

**Latency histograms (not just averages):**

```python
metrics.histogram("downstream.latency_ms", value=duration_ms, tags=tags)
# Stored as a distribution → can compute p50/p95/p99/p99.9 per tag combination
# vs metrics.gauge("...avg_latency...") which loses tail information
```

**Symptom of missing per-source observability:**
- "Something seems slow but we don't know what" — symptom of mush metrics
- Outage debugging involves grepping logs
- "We didn't know Personalize was degraded for 30 minutes" — no per-source alerting

Reference: [Datadog — Custom metrics](https://docs.datadoghq.com/metrics/custom_metrics/) | [OpenTelemetry — Semantic conventions](https://opentelemetry.io/docs/specs/semconv/)
