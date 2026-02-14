---
title: Implement LRU Eviction in Shared Memory Cache Zones
impact: MEDIUM
impactDescription: prevents shared memory exhaustion under diverse request patterns
tags: cache, lru, shared-memory, eviction
---

## Implement LRU Eviction in Shared Memory Cache Zones

Shared memory zones have fixed capacity. Without an eviction strategy, the slab allocator returns `NULL` once the zone is full, and every subsequent cache-miss request falls through to the upstream — effectively disabling caching for the rest of the process lifetime. Maintaining an LRU queue with `ngx_queue_t` lets you evict the oldest entry on allocation failure, keeping the cache effective under diverse key sets without requiring a restart or zone resize.

**Incorrect (allocates without eviction — cache becomes permanently full):**

```c
typedef struct {
    ngx_rbtree_t         rbtree;
    ngx_rbtree_node_t    sentinel;
} my_cache_shm_t;

typedef struct {
    ngx_rbtree_node_t    node;
    ngx_str_t            value;
    uint32_t             key_hash;
} my_cache_entry_t;

static my_cache_entry_t *
my_cache_insert(ngx_shm_zone_t *zone, uint32_t hash, ngx_str_t *val,
    ngx_log_t *log)
{
    ngx_slab_pool_t    *shpool;
    my_cache_shm_t     *cache;
    my_cache_entry_t   *entry;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;
    cache = (my_cache_shm_t *) shpool->data;

    ngx_shmtx_lock(&shpool->mutex);

    /* BAD: when zone is full, alloc returns NULL and every miss hits upstream */
    entry = ngx_slab_alloc_locked(shpool, sizeof(my_cache_entry_t));
    if (entry == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        ngx_log_error(NGX_LOG_ERR, log, 0, "cache zone full, no eviction");
        return NULL;
    }

    entry->node.key = hash;
    entry->key_hash = hash;
    entry->value = *val;

    ngx_rbtree_insert(&cache->rbtree, &entry->node);

    ngx_shmtx_unlock(&shpool->mutex);

    return entry;
}
```

**Correct (maintains LRU queue and evicts oldest entry on allocation failure):**

```c
typedef struct {
    ngx_rbtree_t         rbtree;
    ngx_rbtree_node_t    sentinel;
    ngx_queue_t          lru_queue;   /* LRU: head = newest, tail = oldest */
} my_cache_shm_t;

typedef struct {
    ngx_rbtree_node_t    node;
    ngx_queue_t          queue;       /* link into lru_queue */
    ngx_str_t            value;
    uint32_t             key_hash;
} my_cache_entry_t;

/* evicts LRU tail: ngx_queue_last → rbtree_delete → slab_free_locked */
static void my_cache_evict_oldest(ngx_slab_pool_t *, my_cache_shm_t *);

static my_cache_entry_t *
my_cache_insert(ngx_shm_zone_t *zone, uint32_t hash, ngx_str_t *val,
    ngx_log_t *log)
{
    ngx_slab_pool_t    *shpool;
    my_cache_shm_t     *cache;
    my_cache_entry_t   *entry;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;
    cache = (my_cache_shm_t *) shpool->data;

    ngx_shmtx_lock(&shpool->mutex);

    entry = ngx_slab_alloc_locked(shpool, sizeof(my_cache_entry_t));
    if (entry == NULL) {
        /* evict LRU entry and retry allocation */
        my_cache_evict_oldest(shpool, cache);
        entry = ngx_slab_alloc_locked(shpool, sizeof(my_cache_entry_t));
    }

    if (entry == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        ngx_log_error(NGX_LOG_ALERT, log, 0,
                      "cache zone full even after LRU eviction");
        return NULL;
    }

    entry->node.key = hash;
    entry->key_hash = hash;
    entry->value = *val;

    ngx_rbtree_insert(&cache->rbtree, &entry->node);
    ngx_queue_insert_head(&cache->lru_queue, &entry->queue);

    ngx_shmtx_unlock(&shpool->mutex);

    return entry;
}
```
