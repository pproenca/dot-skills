---
title: Perform Slab Allocation Outside Hot Path
impact: MEDIUM-HIGH
impactDescription: prevents slab allocator lock contention during request processing
tags: lock, slab, preallocation, hot-path
---

## Perform Slab Allocation Outside Hot Path

`ngx_slab_alloc` acquires the shared zone mutex internally and may trigger slab page splitting or garbage collection, holding the lock for an unpredictable duration. Calling it during request processing turns the slab allocator into a serialization point across all workers. Pre-allocate slots during module init or maintain a free-list of reusable entries so the hot path never enters the slab allocator.

**Incorrect (allocates from slab on every request):**

```c
static ngx_int_t
ngx_http_session_handler(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t   *shpool;
    my_session_t      *sess;
    my_shm_data_t     *data;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    data = (my_shm_data_t *) shpool->data;

    /* BAD: slab alloc on every new session request — under load this
       triggers page splitting while all other workers wait on the mutex */
    sess = ngx_slab_alloc_locked(shpool, sizeof(my_session_t));
    if (sess == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_HTTP_SERVICE_UNAVAILABLE;
    }

    ngx_memzero(sess, sizeof(my_session_t));
    sess->start = ngx_current_msec;

    ngx_queue_insert_head(&data->active_sessions, &sess->queue);

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```

**Correct (pre-allocates a free-list during init, hot path pops from free-list):**

```c
static ngx_int_t
ngx_http_session_init_zone(ngx_shm_zone_t *zone, void *data)
{
    ngx_slab_pool_t   *shpool;
    my_shm_data_t     *shdata;
    my_session_t      *sess;
    ngx_uint_t         i;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    shdata = ngx_slab_alloc(shpool, sizeof(my_shm_data_t));
    if (shdata == NULL) {
        return NGX_ERROR;
    }

    ngx_queue_init(&shdata->active_sessions);
    ngx_queue_init(&shdata->free_sessions);

    /* pre-allocate session slots at init — no slab alloc at runtime */
    for (i = 0; i < 4096; i++) {
        sess = ngx_slab_alloc(shpool, sizeof(my_session_t));
        if (sess == NULL) {
            return NGX_ERROR;
        }
        ngx_queue_insert_tail(&shdata->free_sessions, &sess->queue);
    }

    shpool->data = shdata;
    zone->data = shdata;

    return NGX_OK;
}

static ngx_int_t
ngx_http_session_handler(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t   *shpool;
    my_session_t      *sess;
    my_shm_data_t     *data;
    ngx_queue_t       *q;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    data = (my_shm_data_t *) shpool->data;

    if (ngx_queue_empty(&data->free_sessions)) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_HTTP_SERVICE_UNAVAILABLE;
    }

    /* fast path: pop from pre-allocated free-list — no slab allocator */
    q = ngx_queue_last(&data->free_sessions);
    ngx_queue_remove(q);

    sess = ngx_queue_data(q, my_session_t, queue);
    ngx_memzero(sess, sizeof(my_session_t));
    sess->start = ngx_current_msec;

    ngx_queue_insert_head(&data->active_sessions, &sess->queue);

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```
