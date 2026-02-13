---
title: Track Request Reference Count to Debug Premature Destruction
impact: MEDIUM
impactDescription: prevents use-after-free from request count reaching zero early
tags: state, request, count, reference, finalize
---

## Track Request Reference Count to Debug Premature Destruction

The `r->count` field tracks how many async operations reference a request. When `ngx_http_finalize_request` is called and `r->count` drops to zero, the request is destroyed and its memory pool freed. If an async operation (subrequest, body read, posted event) completes after `r->count` has already hit zero, it accesses freed memory. Conversely, if `r->count` is incremented but never decremented, the request leaks and the connection is never closed. Logging `r->count` at each increment/decrement point reveals exactly where the count diverges from expectations.

**Incorrect (not incrementing r->count before starting an async operation):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_ctx_t  *ctx;

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    /* BUG: starting an async body read without incrementing
     * r->count. If the client sends headers only and closes
     * the connection, the read handler may complete with EOF
     * and call ngx_http_finalize_request(r, 0).
     *
     * Meanwhile, the phase handler already returned NGX_DONE,
     * so nginx's HTTP state machine also calls
     * ngx_http_finalize_request(r, NGX_DONE).
     *
     * Without r->count protection, the second finalize finds
     * r->pool already destroyed — use-after-free. */

    r->request_body_in_single_buf = 1;

    /* BAD: missing r->count++ before async operation */
    ngx_int_t rc = ngx_http_read_client_request_body(r,
                       ngx_http_mymodule_body_handler);

    if (rc >= NGX_HTTP_SPECIAL_RESPONSE) {
        return rc;
    }

    return NGX_DONE;
}

static void
ngx_http_mymodule_body_handler(ngx_http_request_t *r)
{
    /* BAD: no r->count-- to balance.
     * If we had incremented, we'd need to decrement here. */
    ngx_http_mymodule_process_body(r);
    ngx_http_finalize_request(r, NGX_OK);
}
```

**Correct (logging r->count at each transition and maintaining correct balance):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_int_t                 rc;
    ngx_http_mymodule_ctx_t  *ctx;

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: handler entry, r->count=%d", r->count);

    /* Increment r->count to prevent premature destruction
     * while the async body read is in progress.
     * ngx_http_read_client_request_body does this internally
     * in modern nginx, but log for clarity. */
    r->main->count++;

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: incremented r->count=%d (body read)",
                   r->main->count);

    r->request_body_in_single_buf = 1;

    rc = ngx_http_read_client_request_body(r,
             ngx_http_mymodule_body_handler);

    if (rc >= NGX_HTTP_SPECIAL_RESPONSE) {
        /* Body read failed synchronously — decrement count
         * since the callback won't be called */
        r->main->count--;
        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                       "mymodule: sync error, r->count=%d",
                       r->main->count);
        return rc;
    }

    return NGX_DONE;
}

static void
ngx_http_mymodule_body_handler(ngx_http_request_t *r)
{
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: body handler entry, r->count=%d",
                   r->main->count);

    ngx_http_mymodule_process_body(r);

    /* ngx_http_finalize_request decrements r->count internally.
     * Our earlier r->count++ ensures the request survives until
     * this point. The finalize call here will decrement back,
     * and if no other async ops are pending, the request is
     * destroyed cleanly. */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: finalizing, r->count=%d (will decrement)",
                   r->main->count);

    ngx_http_finalize_request(r, NGX_OK);
}
```

Reference: [nginx Development Guide — HTTP Request](https://nginx.org/en/docs/dev/development_guide.html#http_request)
