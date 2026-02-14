---
title: Collect Metrics via Shared Memory Counters
impact: LOW-MEDIUM
impactDescription: eliminates per-request disk write() by aggregating counters in shared memory
tags: log, metrics, shared-memory, atomic
---

## Collect Metrics via Shared Memory Counters

Logging every metric value as a text line (request latency, status codes, byte counts) generates enormous I/O volume under load and makes real-time aggregation impossible without external log parsing. Instead, use `ngx_atomic_fetch_add` to increment counters in a shared memory zone and expose the aggregated values through a lightweight status handler. This eliminates per-request disk writes entirely and provides instant metric reads at negligible cost.

**Incorrect (logs every metric value as a text line, causing high I/O):**

```c
static ngx_int_t
ngx_http_metrics_log_handler(ngx_http_request_t *r)
{
    ngx_time_t   *tp;
    ngx_msec_t    latency;

    tp = ngx_timeofday();
    latency = (tp->sec - r->start_sec) * 1000 + (tp->msec - r->start_msec);

    /* BAD: writes to disk on every single request — disk I/O
     * becomes the bottleneck under load, not the upstream */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "METRIC status=%ui latency=%Mms bytes=%O",
                  r->headers_out.status, latency,
                  r->connection->sent);

    return NGX_DECLINED;
}
```

**Correct (atomically increments shared memory counters, exposed via status handler):**

```c
typedef struct {
    ngx_atomic_t    requests;
    ngx_atomic_t    status_2xx;
    ngx_atomic_t    status_5xx;
    ngx_atomic_t    total_bytes;
    ngx_atomic_t    total_latency_ms;
} ngx_http_metrics_shm_t;

static ngx_int_t
ngx_http_metrics_log_handler(ngx_http_request_t *r)
{
    ngx_http_metrics_shm_t  *m;
    ngx_time_t              *tp;
    ngx_msec_t               latency;

    m = metrics_shm_zone->data;

    tp = ngx_timeofday();
    latency = (tp->sec - r->start_sec) * 1000 + (tp->msec - r->start_msec);

    /* lock-free counter updates — no I/O, no contention */
    ngx_atomic_fetch_add(&m->requests, 1);
    ngx_atomic_fetch_add(&m->total_bytes, r->connection->sent);
    ngx_atomic_fetch_add(&m->total_latency_ms, latency);

    if (r->headers_out.status >= 200 && r->headers_out.status < 300) {
        ngx_atomic_fetch_add(&m->status_2xx, 1);
    } else if (r->headers_out.status >= 500) {
        ngx_atomic_fetch_add(&m->status_5xx, 1);
    }

    return NGX_DECLINED;
}

/* expose via status handler: read atomic counters, format with ngx_sprintf */
/* static ngx_int_t ngx_http_metrics_status_handler(ngx_http_request_t *r) */
```
