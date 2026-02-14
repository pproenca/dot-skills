---
title: Use Pre-Allocated Free List for Module Data Structures
impact: MEDIUM
impactDescription: eliminates per-request allocation overhead in hot path
tags: worker, preallocation, init-process, hot-path
---

## Use Pre-Allocated Free List for Module Data Structures

Allocating module-specific data structures on every request introduces pool fragmentation and allocation overhead in the hot path. When the structure size and maximum concurrency are known (e.g., one context per connection), pre-allocating a slab in `init_process` and recycling entries via a free list eliminates per-request `ngx_palloc` calls entirely -- turning a ~30ns allocation into a ~2ns pointer swap on every request.

**Incorrect (allocates module context from request pool on every request):**

```c
typedef struct {
    ngx_buf_t    scratch;
    u_char       digest[32];
    ngx_uint_t   state;
} ngx_http_mymodule_ctx_t;

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_ctx_t  *ctx;

    /* BUG: allocates 72+ bytes from the request pool on every single
     * request — under 50k req/s this is 3.6M allocations per minute,
     * fragmenting pools and pressuring the allocator in the hot path */
    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    /* ... process request ... */

    return NGX_OK;
}
```

**Correct (pre-allocates contexts at worker init and recycles via free list):**

```c
typedef struct {
    ngx_buf_t    scratch;
    u_char       digest[32];
    ngx_uint_t   state;
} ngx_http_mymodule_ctx_t;

/* per-worker free list — no lock needed, single-threaded */
static ngx_http_mymodule_ctx_t  *ctx_free_list;

static ngx_int_t
ngx_http_mymodule_init_process(ngx_cycle_t *cycle)
{
    ngx_http_mymodule_ctx_t  *pool_block, *entry;
    ngx_uint_t                i, n;

    n = cycle->connection_n;
    pool_block = ngx_alloc(n * sizeof(ngx_http_mymodule_ctx_t), cycle->log);
    if (pool_block == NULL) { return NGX_ERROR; }

    /* intrusive singly-linked free list */
    ctx_free_list = NULL;
    for (i = 0; i < n; i++) {
        entry = &pool_block[i];
        *(ngx_http_mymodule_ctx_t **) entry = ctx_free_list;
        ctx_free_list = entry;
    }
    return NGX_OK;
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_ctx_t  *ctx;
    ngx_pool_cleanup_t       *cln;

    if (ctx_free_list == NULL) {
        /* fallback: all pre-allocated contexts in use */
        ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
        if (ctx == NULL) {
            return NGX_ERROR;
        }
    } else {
        /* ~2ns pointer swap instead of pool allocation */
        ctx = ctx_free_list;
        ctx_free_list = *(ngx_http_mymodule_ctx_t **) ctx;
        ngx_memzero(ctx, sizeof(ngx_http_mymodule_ctx_t));

        /* register cleanup to return ctx to free list on request end */
        cln = ngx_pool_cleanup_add(r->pool, 0);
        if (cln == NULL) { return NGX_ERROR; }
        cln->handler = ngx_http_mymodule_ctx_release;
        cln->data = ctx;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    return NGX_OK;
}
```

**Note:** The free list is per-worker and accessed only from the event loop thread, so no locking is required. Register a `ngx_pool_cleanup_t` handler to return the context to the free list when the request pool is destroyed.
