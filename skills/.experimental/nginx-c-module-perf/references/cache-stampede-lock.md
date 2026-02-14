---
title: Prevent Cache Stampede with Single-Flight Pattern
impact: MEDIUM
impactDescription: reduces upstream load from N concurrent misses to 1 fetch + N-1 waits
tags: cache, stampede, lock, single-flight
---

## Prevent Cache Stampede with Single-Flight Pattern

When a popular cache key expires, every concurrent request that encounters the miss will independently fetch from the upstream, multiplying backend load by the concurrency factor. Under high traffic this thundering-herd effect can overwhelm the upstream or saturate worker connections. A single-flight pattern uses a lock flag in the shared cache entry so that only the first request fetches while subsequent requests wait or return stale data until the entry is repopulated.

**Incorrect (all concurrent requests independently fetch on cache miss):**

```c
typedef struct {
    ngx_rbtree_node_t    node;
    ngx_queue_t          queue;
    ngx_str_t            value;
    time_t               expires;
    uint32_t             key_hash;
} my_cache_entry_t;

static ngx_int_t
my_cache_lookup(ngx_http_request_t *r, ngx_shm_zone_t *zone,
    uint32_t hash, ngx_str_t *result)
{
    ngx_slab_pool_t    *shpool;
    my_cache_entry_t   *entry;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    entry = my_cache_find_locked(zone, hash);

    if (entry == NULL || entry->expires < ngx_time()) {
        ngx_shmtx_unlock(&shpool->mutex);
        /* BAD: every concurrent miss triggers a separate upstream fetch —
         * 100 concurrent requests = 100 upstream calls for the same key */
        return my_fetch_from_upstream(r, zone, hash, result);
    }

    *result = entry->value;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```

**Correct (uses lock flag so only the first miss fetches, others wait or get stale):**

```c
typedef struct {
    ngx_rbtree_node_t    node;
    ngx_queue_t          queue;
    ngx_str_t            value;
    time_t               expires;
    uint32_t             key_hash;
    unsigned             fetching:1;    /* single-flight lock flag */
} my_cache_entry_t;

static ngx_int_t
my_cache_lookup(ngx_http_request_t *r, ngx_shm_zone_t *zone,
    uint32_t hash, ngx_str_t *result)
{
    ngx_slab_pool_t    *shpool;
    my_cache_entry_t   *entry;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    entry = my_cache_find_locked(zone, hash);

    if (entry != NULL && entry->expires >= ngx_time()) {
        /* cache hit — promote in LRU and return */
        *result = entry->value;
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_OK;
    }

    if (entry != NULL && entry->fetching) {
        /* another worker is already fetching — serve stale value */
        *result = entry->value;
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_OK;
    }

    /* first miss: claim the fetch lock */
    if (entry == NULL) {
        entry = my_cache_create_locked(shpool, zone, hash);
        if (entry == NULL) {
            ngx_shmtx_unlock(&shpool->mutex);
            return NGX_ERROR;
        }
    }

    entry->fetching = 1;

    ngx_shmtx_unlock(&shpool->mutex);

    /* only this worker fetches from upstream */
    ngx_int_t rc = my_fetch_from_upstream(r, zone, hash, result);

    ngx_shmtx_lock(&shpool->mutex);

    if (rc == NGX_OK) {
        entry->value = *result;
        entry->expires = ngx_time() + 60;
    }

    entry->fetching = 0;   /* release single-flight lock */

    ngx_shmtx_unlock(&shpool->mutex);

    return rc;
}
```
