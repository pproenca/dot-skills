---
title: Track Request Reference Count to Debug Premature Destruction
impact: MEDIUM
impactDescription: identifies request leak or use-after-free root cause in minutes vs hours of blind debugging
tags: state, request, count, reference, finalize
---

## Track Request Reference Count to Debug Premature Destruction

The `r->main->count` field tracks how many async operations reference a request. When `ngx_http_finalize_request` is called and `r->main->count` drops to zero, the request is destroyed and its memory pool freed. If count is too low, a finalize destroys the request while an async operation is still pending (use-after-free). If count is too high, the request is never freed (connection leak). Logging `r->main->count` at each transition reveals exactly where the count diverges from expectations.

**Note:** Functions like `ngx_http_read_client_request_body()` and `ngx_http_subrequest()` increment `r->main->count` internally. Do NOT manually increment before calling them — double-incrementing causes request leaks.

**Incorrect (no r->count logging, count mismatch is invisible):**

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

    r->request_body_in_single_buf = 1;

    /* BUG: no logging of r->count — when body read completes
     * and the request is destroyed prematurely (or leaks),
     * there is no trace showing where count went wrong */
    ngx_http_read_client_request_body(r,
        ngx_http_mymodule_body_handler);

    return NGX_DONE;
}

static void
ngx_http_mymodule_body_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_process_body(r);
    ngx_http_finalize_request(r, NGX_OK);
}
```

**Correct (logging r->count at each transition to trace count lifecycle):**

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
                   "mymodule: handler entry, r->count=%d",
                   r->main->count);

    r->request_body_in_single_buf = 1;

    /* ngx_http_read_client_request_body increments r->main->count
     * internally — do not increment manually */
    rc = ngx_http_read_client_request_body(r,
             ngx_http_mymodule_body_handler);

    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: after body read, r->count=%d rc=%i",
                   r->main->count, rc);

    if (rc >= NGX_HTTP_SPECIAL_RESPONSE) {
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

    /* ngx_http_finalize_request decrements r->main->count.
     * Log before finalizing to trace the decrement. */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: finalizing, r->count=%d (will decrement)",
                   r->main->count);

    ngx_http_finalize_request(r, NGX_OK);
}
```

Reference: [nginx Development Guide — HTTP Request](https://nginx.org/en/docs/dev/development_guide.html#http_request)
