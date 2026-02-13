---
title: Use Atomic Timestamp Comparison for TTL Expiry Checks
impact: LOW-MEDIUM
impactDescription: avoids mutex lock for read-only TTL validation
tags: cache, ttl, atomic, expiry
---

## Use Atomic Timestamp Comparison for TTL Expiry Checks

Checking whether a cache entry has expired is a read-only operation — it only compares the entry's stored timestamp against the current time. Acquiring the shared memory mutex for this check serializes all workers on every cache probe, even when the entry is still valid and no mutation is needed. By storing the expiry as an `ngx_atomic_t` and reading it with `ngx_atomic_fetch_add(&expires, 0)` (a no-op add that returns the current value atomically), you skip the mutex on the expired-entry fast path. Cache hits still require the mutex to safely read the value pointer, but expired entries return immediately without locking.

**Incorrect (locks mutex just to check expiry timestamp):**

```c
typedef struct {
    ngx_rbtree_node_t    node;
    ngx_queue_t          queue;
    ngx_str_t            value;
    time_t               expires;       /* plain time_t, needs mutex to read safely */
    uint32_t             key_hash;
} my_cache_entry_t;

static ngx_int_t
my_cache_check_ttl(ngx_shm_zone_t *zone, my_cache_entry_t *entry,
    ngx_str_t *result)
{
    ngx_slab_pool_t  *shpool;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    /* BAD: full mutex round-trip just to compare two timestamps */
    ngx_shmtx_lock(&shpool->mutex);

    if (entry->expires < ngx_time()) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_DECLINED;    /* expired */
    }

    *result = entry->value;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```

**Correct (atomic read of expiry timestamp avoids mutex for TTL check):**

```c
typedef struct {
    ngx_rbtree_node_t    node;
    ngx_queue_t          queue;
    ngx_str_t            value;
    ngx_atomic_t         expires;       /* atomic — safe to read without mutex */
    uint32_t             key_hash;
} my_cache_entry_t;

static ngx_int_t
my_cache_check_ttl(ngx_shm_zone_t *zone, my_cache_entry_t *entry,
    ngx_str_t *result)
{
    ngx_slab_pool_t  *shpool;
    time_t            exp;

    /* lock-free TTL check: atomic read of expiry, compare with cached time */
    exp = (time_t) ngx_atomic_fetch_add(&entry->expires, 0);

    if (exp < ngx_time()) {
        return NGX_DECLINED;    /* expired — caller can lock and evict */
    }

    /* cache hit — still need mutex to read the value safely
     * (value.data is a pointer that could be freed concurrently) */
    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);
    *result = entry->value;
    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```
