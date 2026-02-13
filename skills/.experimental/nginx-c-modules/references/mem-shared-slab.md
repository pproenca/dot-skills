---
title: Use Slab Allocator for Shared Memory Zones
impact: MEDIUM
impactDescription: prevents data corruption across worker processes
tags: mem, shared-memory, slab, mutex
---

## Use Slab Allocator for Shared Memory Zones

Worker processes share memory zones for cross-process state such as rate counters, caches, and session stores. All access to shared memory must use `ngx_slab_alloc` for allocation and be protected by the zone's built-in mutex. Missing locks cause race conditions where concurrent workers corrupt shared data structures, producing intermittent and hard-to-diagnose failures.

**Incorrect (unprotected shared memory access):**

```c
static ngx_int_t
ngx_http_mymodule_increment(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    my_shm_data_t     *data;
    ngx_slab_pool_t   *shpool;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;
    data = (my_shm_data_t *) shpool->data;

    /* BUG: no mutex — two workers can read-modify-write simultaneously */
    data->counter++;

    /* BUG: ngx_slab_alloc without lock — corrupts slab free lists */
    data->entry = ngx_slab_alloc(shpool, sizeof(my_entry_t));

    return NGX_OK;
}
```

**Correct (mutex-protected shared memory access with slab allocation):**

```c
static ngx_int_t
ngx_http_mymodule_increment(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    my_shm_data_t     *data;
    my_entry_t        *entry;
    ngx_slab_pool_t   *shpool;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    data = (my_shm_data_t *) shpool->data;
    data->counter++;

    entry = ngx_slab_alloc_locked(shpool, sizeof(my_entry_t));
    if (entry == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "slab alloc failed in shared zone");
        return NGX_ERROR;
    }

    data->entry = entry;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```

**Note:** Use `ngx_slab_alloc_locked` when you already hold the mutex to avoid a deadlock on re-locking. Use `ngx_slab_alloc` (which locks internally) only when you are not holding the mutex. Always minimize the critical section to reduce lock contention across workers.
