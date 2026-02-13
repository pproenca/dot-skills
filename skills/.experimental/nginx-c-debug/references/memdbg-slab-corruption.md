---
title: Diagnose Shared Memory Slab Corruption from Multi-Worker Crashes
impact: CRITICAL
impactDescription: corrupts shared state, crashes all workers
tags: memdbg, shared-memory, slab, corruption, mutex
---

## Diagnose Shared Memory Slab Corruption from Multi-Worker Crashes

Modifying shared data structures (rbtrees, counters, hash tables) in a slab zone without holding the mutex corrupts those structures and the slab metadata they reference. `ngx_slab_alloc()` self-locks internally, so the allocation itself is safe — but the surrounding operations (rbtree inserts, counter increments) are not. The corruption manifests as crashes in `ngx_slab_alloc` or `ngx_slab_free` in any worker process, not just the one that caused the corruption. The crash backtrace points to slab internals rather than the offending module, making root-cause analysis difficult. The fix is to lock externally with `ngx_shmtx_lock` and use `ngx_slab_alloc_locked()` so all operations share a single critical section.

**Incorrect (updates shared memory counter without acquiring the shmtx lock):**

```c
typedef struct {
    ngx_rbtree_t      rbtree;
    ngx_rbtree_node_t sentinel;
    ngx_uint_t        total_entries;
} my_shm_data_t;

static ngx_int_t
ngx_http_mymodule_add_entry(ngx_http_request_t *r, ngx_shm_zone_t *zone,
    ngx_str_t *key)
{
    ngx_slab_pool_t    *shpool;
    my_shm_data_t      *data;
    ngx_rbtree_node_t  *node;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;
    data = (my_shm_data_t *) shpool->data;

    /* BUG: ngx_slab_alloc() self-locks so the alloc is safe, but
     * ngx_rbtree_insert and total_entries++ below have NO lock —
     * concurrent workers corrupt the rbtree structure, causing
     * crashes in ngx_slab_alloc or ngx_slab_free later */
    node = ngx_slab_alloc(shpool, sizeof(ngx_rbtree_node_t) + key->len);
    if (node == NULL) {
        return NGX_ERROR;
    }

    node->key = ngx_crc32_short(key->data, key->len);
    ngx_rbtree_insert(&data->rbtree, node);
    data->total_entries++;

    return NGX_OK;
}
```

**Correct (locks before slab operations; uses atomic operations for simple counters):**

```c
typedef struct {
    ngx_rbtree_t      rbtree;
    ngx_rbtree_node_t sentinel;
    ngx_atomic_t      total_entries;  /* atomic for lock-free reads */
} my_shm_data_t;

static ngx_int_t
ngx_http_mymodule_add_entry(ngx_http_request_t *r, ngx_shm_zone_t *zone,
    ngx_str_t *key)
{
    ngx_slab_pool_t    *shpool;
    my_shm_data_t      *data;
    ngx_rbtree_node_t  *node;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;
    data = (my_shm_data_t *) shpool->data;

    /* SAFE: lock protects both slab allocator metadata and rbtree structure */
    ngx_shmtx_lock(&shpool->mutex);

    node = ngx_slab_alloc_locked(shpool,
                                 sizeof(ngx_rbtree_node_t) + key->len);
    if (node == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_ERROR;
    }

    node->key = ngx_crc32_short(key->data, key->len);
    ngx_rbtree_insert(&data->rbtree, node);

    ngx_shmtx_unlock(&shpool->mutex);

    /* counter can be updated atomically outside the lock */
    ngx_atomic_fetch_add(&data->total_entries, 1);

    return NGX_OK;
}
```

Reference: [nginx Development Guide — Shared Memory](https://nginx.org/en/docs/dev/development_guide.html#shared_memory)
