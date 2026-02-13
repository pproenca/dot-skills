---
title: Cache Only Successful Responses to Avoid Negative Cache Pollution
impact: LOW-MEDIUM
impactDescription: prevents error responses from being served as cached content
tags: cache, conditional, status, pollution
---

## Cache Only Successful Responses to Avoid Negative Cache Pollution

Caching every upstream response regardless of HTTP status pollutes the cache with 5xx errors, 404s, and other transient failures. Once a 502 or 503 is stored, every subsequent request for that key receives the error response for the full TTL duration — turning a momentary upstream blip into sustained user-facing failures. Always check the upstream status code before committing a response to the cache, and only store responses that represent valid, serveable content.

**Incorrect (caches all upstream responses including errors):**

```c
static ngx_int_t
my_cache_store_response(ngx_http_request_t *r, ngx_shm_zone_t *zone,
    uint32_t hash)
{
    ngx_slab_pool_t    *shpool;
    my_cache_entry_t   *entry;
    ngx_str_t           body;

    /* BAD: stores response without checking status — a 502 from upstream
     * gets cached and served to all users for the entire TTL */
    body.data = r->upstream->buffer.pos;
    body.len = r->upstream->buffer.last - r->upstream->buffer.pos;

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    entry = my_cache_find_or_create_locked(shpool, zone, hash);
    if (entry == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_ERROR;
    }

    entry->value.data = ngx_slab_alloc_locked(shpool, body.len);
    if (entry->value.data == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_ERROR;
    }

    ngx_memcpy(entry->value.data, body.data, body.len);
    entry->value.len = body.len;
    entry->expires = ngx_time() + 60;
    entry->status = r->upstream->headers_in.status_n;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```

**Correct (checks status code before caching, rejects error responses):**

```c
static ngx_int_t
my_cache_store_response(ngx_http_request_t *r, ngx_shm_zone_t *zone,
    uint32_t hash)
{
    ngx_slab_pool_t    *shpool;
    my_cache_entry_t   *entry;
    ngx_str_t           body;
    ngx_uint_t          status;

    status = r->upstream->headers_in.status_n;

    /* only cache 2xx responses — reject errors, redirects, and auth challenges */
    if (status < 200 || status >= 300) {
        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "cache skip: upstream returned status %ui", status);
        return NGX_DECLINED;
    }

    body.data = r->upstream->buffer.pos;
    body.len = r->upstream->buffer.last - r->upstream->buffer.pos;

    /* reject empty bodies even on 200 — likely an upstream misconfiguration */
    if (body.len == 0) {
        return NGX_DECLINED;
    }

    shpool = (ngx_slab_pool_t *) zone->shm.addr;

    ngx_shmtx_lock(&shpool->mutex);

    entry = my_cache_find_or_create_locked(shpool, zone, hash);
    if (entry == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_ERROR;
    }

    /* free previous value if overwriting a stale entry */
    if (entry->value.data) {
        ngx_slab_free_locked(shpool, entry->value.data);
    }

    entry->value.data = ngx_slab_alloc_locked(shpool, body.len);
    if (entry->value.data == NULL) {
        ngx_shmtx_unlock(&shpool->mutex);
        return NGX_ERROR;
    }

    ngx_memcpy(entry->value.data, body.data, body.len);
    entry->value.len = body.len;
    entry->expires = ngx_time() + 60;
    entry->status = status;

    ngx_shmtx_unlock(&shpool->mutex);

    return NGX_OK;
}
```
