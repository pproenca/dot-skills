---
title: Minimize Critical Section Duration in Shared Memory
impact: HIGH
impactDescription: reduces lock hold time from microseconds to nanoseconds, enabling linear worker scaling
tags: lock, critical-section, shmtx, scaling
---

## Minimize Critical Section Duration in Shared Memory

Every nanosecond a worker holds the shared memory mutex is a nanosecond other workers spin or sleep waiting for it. Performing computation, string formatting, or data transformation inside the critical section serializes all workers through a single bottleneck. Prepare all data in worker-local memory first, then enter the critical section only for the final pointer swap or memcpy.

**Incorrect (performs computation and formatting while holding the mutex):**

```c
static ngx_int_t
ngx_http_stats_update(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t   *shpool;
    my_shm_stats_t    *stats;
    ngx_time_t        *tp;
    u_char             buf[128];
    size_t             len;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    stats = (my_shm_stats_t *) shpool->data;

    /* BAD: time computation inside critical section */
    tp = ngx_timeofday();
    stats->last_access = tp->sec * 1000 + tp->msec;

    /* BAD: string formatting inside critical section */
    len = ngx_snprintf(buf, sizeof(buf), "%V:%ui",
                       &r->uri, r->headers_out.status)
          - buf;

    stats->last_uri.data = ngx_slab_alloc_locked(shpool, len);
    if (stats->last_uri.data == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_ERROR;
    }

    ngx_memcpy(stats->last_uri.data, buf, len);
    stats->last_uri.len = len;

    /* BAD: latency histogram computation under lock */
    stats->bucket[ngx_http_stats_latency_bucket(r)]++;
    stats->total_requests++;
    stats->total_latency += ngx_http_stats_request_ms(r);

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```

**Correct (prepares all data outside lock, enters critical section only for memcpy and counter updates):**

```c
static ngx_int_t
ngx_http_stats_update(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t   *shpool;
    my_shm_stats_t    *stats;
    ngx_msec_t         now;
    ngx_uint_t         bucket;
    ngx_msec_int_t     latency;
    u_char             buf[128];
    size_t             len;

    /* prepare everything in worker-local stack */
    now = ngx_current_msec;
    bucket = ngx_http_stats_latency_bucket(r);
    latency = ngx_http_stats_request_ms(r);

    len = ngx_snprintf(buf, sizeof(buf), "%V:%ui",
                       &r->uri, r->headers_out.status)
          - buf;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    /* critical section: only pointer writes and increments */
    stats = (my_shm_stats_t *) shpool->data;
    stats->last_access = now;

    stats->last_uri.data = ngx_slab_alloc_locked(shpool, len);
    if (stats->last_uri.data == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_ERROR;
    }

    ngx_memcpy(stats->last_uri.data, buf, len);
    stats->last_uri.len = len;

    stats->bucket[bucket]++;
    stats->total_requests++;
    stats->total_latency += latency;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```
