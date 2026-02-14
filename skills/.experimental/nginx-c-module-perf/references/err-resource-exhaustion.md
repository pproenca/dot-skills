---
title: Handle Pool and Slab Allocation Exhaustion Gracefully
impact: HIGH
impactDescription: prevents crash under memory pressure, returns 503 instead of segfault
tags: err, exhaustion, slab, graceful
---

## Handle Pool and Slab Allocation Exhaustion Gracefully

Shared memory slab allocations (`ngx_slab_alloc_locked`, `ngx_slab_alloc`) return `NULL` when the zone is full, and pool allocations can fail under extreme memory pressure. Dereferencing the result without a NULL check causes a segfault that kills the entire worker process, taking down every in-flight request on that worker. Always check the return value and degrade to a 503 response, which keeps the worker alive and lets other requests proceed normally.

**Incorrect (dereferences slab alloc result without NULL check, crashes on exhaustion):**

```c
static ngx_int_t
ngx_http_mymodule_shm_store(ngx_http_request_t *r,
    ngx_http_mymodule_shm_t *shm, ngx_str_t *key, ngx_str_t *value)
{
    ngx_http_mymodule_node_t  *node;

    ngx_shmtx_lock(&shm->shpool->mutex);

    /* BUG: if slab is full this returns NULL — next line segfaults */
    node = ngx_slab_alloc_locked(shm->shpool,
                                 sizeof(ngx_http_mymodule_node_t));

    node->key = *key;
    ngx_memcpy(node->value, value->data, value->len);

    ngx_shmtx_unlock(&shm->shpool->mutex);

    return NGX_OK;
}
```

**Correct (checks for NULL and returns 503 to keep the worker alive):**

```c
static ngx_int_t
ngx_http_mymodule_shm_store(ngx_http_request_t *r,
    ngx_http_mymodule_shm_t *shm, ngx_str_t *key, ngx_str_t *value)
{
    ngx_http_mymodule_node_t  *node;

    ngx_shmtx_lock(&shm->shpool->mutex);

    node = ngx_slab_alloc_locked(shm->shpool,
                                 sizeof(ngx_http_mymodule_node_t));
    if (node == NULL) {
        ngx_shmtx_unlock(&shm->shpool->mutex);

        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "shared memory zone \"%V\" exhausted, "
                      "rejecting request with 503", &shm->shm.name);

        /* 503 keeps worker alive — client can retry after zone pressure eases */
        return NGX_HTTP_SERVICE_UNAVAILABLE;
    }

    node->key = *key;
    ngx_memcpy(node->value, value->data, value->len);

    ngx_shmtx_unlock(&shm->shpool->mutex);

    return NGX_OK;
}
```
