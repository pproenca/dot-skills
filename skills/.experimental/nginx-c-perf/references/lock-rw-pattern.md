---
title: Use Read-Copy-Update Pattern for Read-Heavy Shared Data
impact: MEDIUM
impactDescription: enables lock-free reads for data updated infrequently
tags: lock, rcu, read-heavy, pointer-swap
---

## Use Read-Copy-Update Pattern for Read-Heavy Shared Data

When shared data is read on every request but updated rarely (configuration reloads, periodic aggregation), locking the mutex for every read serializes all workers through the same bottleneck. Instead, maintain two copies of the data and an atomic version pointer. Readers load the current pointer atomically with zero locking. Writers prepare the new version in the inactive copy, then atomically swap the pointer. This gives readers wait-free access at the cost of double memory for the shared structure.

**Incorrect (locks mutex on every read of infrequently-updated shared config):**

```c
static ngx_int_t
ngx_http_geoblock_handler(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t    *shpool;
    my_geoblock_t      *geo;
    ngx_uint_t          blocked;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    /* BAD: mutex on every request for data that changes once per hour;
       at 50k rps across 8 workers this is ~400k lock acquisitions/sec */
    ngx_shmtx_lock(&shpool->mutex);

    geo = (my_geoblock_t *) shpool->data;
    blocked = ngx_http_geoblock_lookup(geo->rules, geo->nrules,
                                       r->connection->sockaddr);

    ngx_shmtx_unlock(&shpool->mutex);

    if (blocked) {
        return NGX_HTTP_FORBIDDEN;
    }

    return NGX_DECLINED;
}
```

**Correct (atomic pointer read for lock-free hot path, mutex only on update):**

```c
typedef struct {
    my_geoblock_rules_t    versions[2];    /* double-buffered rule sets */
    ngx_atomic_t           active;         /* index of current version: 0 or 1 */
} my_geoblock_t;

static ngx_int_t
ngx_http_geoblock_handler(ngx_http_request_t *r, ngx_shm_zone_t *zone)
{
    ngx_slab_pool_t        *shpool;
    my_geoblock_t          *geo;
    my_geoblock_rules_t    *current;
    ngx_uint_t              idx, blocked;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;
    geo = (my_geoblock_t *) shpool->data;

    /* lock-free read: atomic load of active index */
    idx = (ngx_uint_t) *((volatile ngx_atomic_t *) &geo->active);
    current = &geo->versions[idx];

    blocked = ngx_http_geoblock_lookup(current->rules, current->nrules,
                                       r->connection->sockaddr);

    if (blocked) {
        return NGX_HTTP_FORBIDDEN;
    }

    return NGX_DECLINED;
}

static void
ngx_http_geoblock_update(ngx_shm_zone_t *zone, my_geoblock_rules_t *new_rules)
{
    ngx_slab_pool_t        *shpool;
    my_geoblock_t          *geo;
    ngx_uint_t              active, inactive;
    my_geoblock_rules_t    *target;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    geo = (my_geoblock_t *) shpool->data;
    active = (ngx_uint_t) geo->active;
    inactive = 1 - active;

    /* write new data into the inactive version */
    target = &geo->versions[inactive];
    ngx_memcpy(target->rules, new_rules->rules,
               new_rules->nrules * sizeof(my_rule_t));
    target->nrules = new_rules->nrules;

    /* atomic pointer swap — readers immediately see new version */
    geo->active = (ngx_atomic_t) inactive;

    ngx_shmtx_unlock(&shpool->mutex);
}
```
