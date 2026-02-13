---
title: Use Atomic Operations for Simple Counters Instead of Mutex
impact: HIGH
impactDescription: 10-50x faster than mutex for counter increments across workers
tags: lock, atomic, counter, lock-free
---

## Use Atomic Operations for Simple Counters Instead of Mutex

Atomic operations on `ngx_atomic_t` variables use CPU-level compare-and-swap instructions that complete in a single bus cycle without acquiring or releasing a mutex. For simple counters (request counts, byte totals, error tallies), replacing a lock/increment/unlock sequence with `ngx_atomic_fetch_add` eliminates all mutex overhead and contention entirely. This is the single most impactful optimization for high-frequency shared counters.

**Incorrect (acquires mutex to increment a simple counter):**

```c
typedef struct {
    ngx_atomic_t    total_requests;
    ngx_atomic_t    total_bytes;
} my_shm_counters_t;

static ngx_int_t
ngx_http_metrics_count(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t     *shpool;
    my_shm_counters_t   *counters;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    /* BAD: full mutex round-trip for a single atomic-safe increment */
    ngx_shmtx_lock(&shpool->mutex);

    counters = (my_shm_counters_t *) shpool->data;
    counters->total_requests++;
    counters->total_bytes += r->headers_out.content_length_n;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```

**Correct (uses ngx_atomic_fetch_add for lock-free counter updates):**

```c
typedef struct {
    ngx_atomic_t    total_requests;
    ngx_atomic_t    total_bytes;
} my_shm_counters_t;

static ngx_int_t
ngx_http_metrics_count(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t     *shpool;
    my_shm_counters_t   *counters;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;
    counters = (my_shm_counters_t *) shpool->data;

    /* lock-free: hardware CAS, no mutex contention */
    ngx_atomic_fetch_add(&counters->total_requests, 1);
    ngx_atomic_fetch_add(&counters->total_bytes,
                         r->headers_out.content_length_n);

    return NGX_OK;
}
```
