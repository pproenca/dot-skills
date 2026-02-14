---
title: Aggregate Per-Worker Counters to Reduce Shared Memory Access
impact: MEDIUM-HIGH
impactDescription: eliminates shared memory contention for high-frequency counters
tags: lock, per-worker, aggregation, counter
---

## Aggregate Per-Worker Counters to Reduce Shared Memory Access

When every request touches a shared memory counter, workers constantly compete for the same cache line and mutex even when using atomics. Instead, accumulate counts in a per-worker local variable and flush to shared memory periodically (every N requests or on a timer). This converts N atomic operations per second into one, eliminating cross-core cache invalidation traffic and shared memory bus contention entirely on the hot path.

**Incorrect (increments shared atomic counter on every single request):**

```c
static ngx_int_t
ngx_http_metrics_handler(ngx_http_request_t *r)
{
    ngx_slab_pool_t     *shpool;
    my_shm_counters_t   *counters;

    shpool = (ngx_slab_pool_t *) my_shm_zone->shm.addr;
    counters = (my_shm_counters_t *) shpool->data;

    /* BAD: atomic on every request — at 100k rps across 8 workers,
       this causes ~800k cross-core cache invalidations per second */
    ngx_atomic_fetch_add(&counters->total_requests, 1);
    ngx_atomic_fetch_add(&counters->total_bytes,
                         r->headers_out.content_length_n);

    return NGX_DECLINED;
}
```

**Correct (accumulates in per-worker local storage, flushes periodically):**

```c
#define MY_FLUSH_INTERVAL  128  /* flush every 128 requests */

typedef struct {
    ngx_uint_t    local_requests;
    ngx_uint_t    local_bytes;
} my_worker_ctx_t;

/* allocated per worker in init_process */
static my_worker_ctx_t  *my_worker_ctx;

static ngx_int_t
ngx_http_metrics_handler(ngx_http_request_t *r)
{
    ngx_slab_pool_t     *shpool;
    my_shm_counters_t   *counters;

    /* fast path: worker-local increment, no shared memory access */
    my_worker_ctx->local_requests++;
    my_worker_ctx->local_bytes += r->headers_out.content_length_n;

    if (my_worker_ctx->local_requests < MY_FLUSH_INTERVAL) {
        return NGX_DECLINED;
    }

    /* slow path: flush accumulated counters to shared memory */
    shpool = (ngx_slab_pool_t *) my_shm_zone->shm.addr;
    counters = (my_shm_counters_t *) shpool->data;

    ngx_atomic_fetch_add(&counters->total_requests,
                         my_worker_ctx->local_requests);
    ngx_atomic_fetch_add(&counters->total_bytes,
                         my_worker_ctx->local_bytes);

    my_worker_ctx->local_requests = 0;
    my_worker_ctx->local_bytes = 0;

    return NGX_DECLINED;
}
```
