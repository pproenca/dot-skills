---
title: Detect Use-After-Free from Pool Destruction Timing
impact: CRITICAL
impactDescription: causes intermittent crashes — reproduces in ~1/1000+ requests when pool reuse timing aligns
tags: memdbg, use-after-free, pool, lifecycle
---

## Detect Use-After-Free from Pool Destruction Timing

When a connection or request pool is destroyed, all memory allocated from it becomes invalid. Saving a pointer from a request pool and accessing it after `ngx_http_finalize_request` completes triggers use-after-free. The bug is intermittent because the freed memory may still contain valid-looking data until it is reallocated by a subsequent request on the same connection.

**Incorrect (stores request pool pointer in connection context, reads it after request completes):**

```c
typedef struct {
    ngx_str_t    cached_uri;   /* points into r->pool memory */
} my_conn_ctx_t;

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_connection_t  *c = r->connection;
    my_conn_ctx_t     *ctx;

    ctx = ngx_pcalloc(c->pool, sizeof(my_conn_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    /* BUG: cached_uri.data points into r->pool — freed when request ends */
    ctx->cached_uri.len = r->uri.len;
    ctx->cached_uri.data = r->uri.data;

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    return NGX_DECLINED;
}

static ngx_int_t
ngx_http_mymodule_log_handler(ngx_http_request_t *r)
{
    my_conn_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    /* BUG: if this runs on a keepalive request, ctx->cached_uri.data
     * from the previous request's pool is already freed */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "previous uri: %V", &ctx->cached_uri);

    return NGX_OK;
}
```

**Correct (copies data to connection pool so it survives request destruction):**

```c
typedef struct {
    ngx_str_t    cached_uri;   /* owns its own copy in c->pool */
} my_conn_ctx_t;

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_connection_t  *c = r->connection;
    my_conn_ctx_t     *ctx;

    ctx = ngx_pcalloc(c->pool, sizeof(my_conn_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    /* SAFE: deep-copy URI data into c->pool, which outlives the request */
    ctx->cached_uri.len = r->uri.len;
    ctx->cached_uri.data = ngx_pnalloc(c->pool, r->uri.len);
    if (ctx->cached_uri.data == NULL) {
        return NGX_ERROR;
    }
    ngx_memcpy(ctx->cached_uri.data, r->uri.data, r->uri.len);

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    return NGX_DECLINED;
}

static ngx_int_t
ngx_http_mymodule_log_handler(ngx_http_request_t *r)
{
    my_conn_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    /* SAFE: cached_uri.data lives in c->pool, valid across keepalive */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "previous uri: %V", &ctx->cached_uri);

    return NGX_OK;
}
```

Reference: [nginx Development Guide — Memory Pools](https://nginx.org/en/docs/dev/development_guide.html#pool)
