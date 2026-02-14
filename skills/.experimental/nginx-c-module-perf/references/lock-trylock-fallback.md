---
title: Use ngx_shmtx_trylock with Fallback to Avoid Worker Stalls
impact: HIGH
impactDescription: prevents worker stall when shared zone is contended
tags: lock, trylock, fallback, contention
---

## Use ngx_shmtx_trylock with Fallback to Avoid Worker Stalls

`ngx_shmtx_lock` blocks the calling worker until the mutex is available, stalling all connections that worker is serving. In request hot paths where the shared data is not strictly required for correctness -- rate limit counters, cache updates, statistics -- use `ngx_shmtx_trylock` to attempt acquisition without blocking. If the lock is contended, fall back to serving stale data, skipping the update, or using a local estimate. This keeps worker latency deterministic under contention.

**Incorrect (unconditional lock blocks worker during contention):**

```c
static ngx_int_t
ngx_http_ratelimit_check(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t    *shpool;
    my_ratelimit_t     *rl;
    ngx_msec_t          now;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    /* BAD: blocks worker — if another worker holds this lock during a
       slab GC or lengthy update, this worker stalls all its connections */
    ngx_shmtx_lock(&shpool->mutex);

    rl = (my_ratelimit_t *) shpool->data;
    now = ngx_current_msec;

    rl->tokens += (now - rl->last_refill) * rl->rate / 1000;
    if (rl->tokens > rl->burst) {
        rl->tokens = rl->burst;
    }
    rl->last_refill = now;

    if (rl->tokens < 1) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_HTTP_TOO_MANY_REQUESTS;
    }

    rl->tokens--;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_DECLINED;
}
```

**Correct (trylock with graceful fallback when contended):**

```c
static ngx_int_t
ngx_http_ratelimit_check(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t    *shpool;
    my_ratelimit_t     *rl;
    ngx_msec_t          now;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    if (!ngx_shmtx_trylock(&shpool->mutex)) {
        /* lock contended — allow request rather than stall worker;
           rate accuracy degrades slightly but latency stays bounded */
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "ratelimit: lock contended, allowing request");
        return NGX_DECLINED;
    }

    rl = (my_ratelimit_t *) shpool->data;
    now = ngx_current_msec;

    rl->tokens += (now - rl->last_refill) * rl->rate / 1000;
    if (rl->tokens > rl->burst) {
        rl->tokens = rl->burst;
    }
    rl->last_refill = now;

    if (rl->tokens < 1) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_HTTP_TOO_MANY_REQUESTS;
    }

    rl->tokens--;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_DECLINED;
}
```
