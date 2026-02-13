---
title: Use Pool Allocation Instead of Heap malloc
impact: CRITICAL
impactDescription: prevents memory leaks across all request-lifetime objects
tags: mem, pool, allocation, memory-management
---

## Use Pool Allocation Instead of Heap malloc

nginx pools automatically free all allocations when the pool is destroyed at request end or connection close. Using `ngx_alloc()` (a `malloc` wrapper) introduces manual memory management that inevitably leaks in error paths, since early returns skip cleanup code.

**Incorrect (heap allocation leaks on error paths):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    /* ngx_alloc wraps malloc — caller must ngx_free manually */
    ctx = ngx_alloc(sizeof(my_ctx_t), r->connection->log);
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ctx->buf = ngx_alloc(4096, r->connection->log);
    if (ctx->buf == NULL) {
        /* BUG: forgot ngx_free(ctx) — leaked on this error path */
        return NGX_ERROR;
    }

    /* every return path must call ngx_free(ctx->buf) + ngx_free(ctx) */
    return NGX_OK;
}
```

**Correct (pool allocation auto-frees with request):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    /* pool allocation — freed automatically when r->pool is destroyed */
    ctx = ngx_palloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ctx->buf = ngx_palloc(r->pool, 4096);
    if (ctx->buf == NULL) {
        /* no leak — ctx is freed when request pool is destroyed */
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Note:** Use `r->pool` for request-scoped data, `cf->pool` for configuration-lifetime data, and `c->pool` for connection-scoped data. Match the pool lifetime to the data lifetime.
