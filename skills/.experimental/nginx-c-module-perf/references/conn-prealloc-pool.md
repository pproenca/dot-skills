---
title: Size Connection Pool to Avoid Runtime Reallocation
impact: HIGH
impactDescription: eliminates pool growth allocations during request processing
tags: conn, pool, preallocation, sizing
---

## Size Connection Pool to Avoid Runtime Reallocation

nginx pools grow by allocating new memory blocks when the current block is exhausted. Each growth triggers a `malloc()` call in the hot path, adding latency and heap fragmentation. The default connection pool size (256 bytes) is tuned for minimal connections but is insufficient for modules that attach context structures, buffers, or parsed headers to the connection pool. Sizing the pool upfront based on expected allocation volume eliminates growth allocations during request processing.

**Incorrect (uses default small pool, causing repeated growth allocations):**

```c
static void
ngx_http_mymodule_init_connection(ngx_event_t *rev)
{
    ngx_connection_t      *c = rev->data;
    my_conn_ctx_t         *ctx;
    my_parsed_header_t    *headers;

    /* c->pool was created with default 256-byte block size;
     * the following allocations exceed it, forcing 2+ pool
     * growth allocations (malloc) in the request hot path */
    ctx = ngx_pcalloc(c->pool, sizeof(my_conn_ctx_t));       /* ~128 bytes */
    if (ctx == NULL) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    ctx->recv_buf = ngx_palloc(c->pool, 4096);               /* forces pool growth */
    if (ctx->recv_buf == NULL) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    headers = ngx_pcalloc(c->pool, sizeof(my_parsed_header_t) * 32);  /* forces another growth */
    if (headers == NULL) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    ctx->headers = headers;
    c->data = ctx;
}
```

**Correct (sizes connection pool based on expected allocation volume):**

```c
static void
ngx_http_mymodule_accept_handler(ngx_event_t *rev)
{
    ngx_connection_t      *c = rev->data;
    ngx_pool_t            *pool;
    my_conn_ctx_t         *ctx;
    my_parsed_header_t    *headers;

    /* pre-calculate total allocation: ctx + recv buffer + headers;
     * create a pool sized to hold everything in a single block */
    pool = ngx_create_pool(
        sizeof(my_conn_ctx_t)                            /* ~128 bytes */
        + 4096                                           /* recv buffer */
        + sizeof(my_parsed_header_t) * 32                /* parsed headers */
        + 256,                                           /* pool overhead + headroom */
        c->log);

    if (pool == NULL) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    /* destroy the old undersized pool and replace it */
    ngx_destroy_pool(c->pool);
    c->pool = pool;

    ctx = ngx_pcalloc(c->pool, sizeof(my_conn_ctx_t));
    if (ctx == NULL) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    ctx->recv_buf = ngx_palloc(c->pool, 4096);
    if (ctx->recv_buf == NULL) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    headers = ngx_pcalloc(c->pool, sizeof(my_parsed_header_t) * 32);
    if (headers == NULL) {
        ngx_http_mymodule_close_connection(c);
        return;
    }

    ctx->headers = headers;
    c->data = ctx;
}
```

**Note:** The `connection_pool_size` directive in `nginx.conf` controls the initial pool size for accepted client connections. For modules that accept their own connections or create upstream connections with `ngx_event_connect_peer`, you must size the pool yourself. A good heuristic: sum the sizes of all structures you will allocate on the pool, add 20% overhead for pool metadata, and round up to the next power of two.
