---
title: Diagnose Double Finalize Crashes from Request Reference Count
impact: CRITICAL
impactDescription: causes cascading worker crashes under load
tags: crash, double-free, finalize, reference-count
---

## Diagnose Double Finalize Crashes from Request Reference Count

Calling `ngx_http_finalize_request` twice on the same request double-decrements `r->main->count`, which can drive it to zero prematurely. When `count` reaches zero, nginx destroys the request pool. Any subsequent access to the request or its pool memory triggers a use-after-free. Under high concurrency this manifests as intermittent segfaults in unrelated code because the freed pool memory gets reallocated to another request. The crash signature typically shows access to apparently valid but incorrect data structures.

**Incorrect (finalize called in both error path and normal callback, double-decrement under error):**

```c
static void
ngx_http_mymodule_upstream_callback(ngx_http_request_t *r,
    ngx_http_upstream_t *u)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    if (u->headers_in.status_n != NGX_HTTP_OK) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "upstream returned %ui", u->headers_in.status_n);
        /* first finalize on error */
        ngx_http_finalize_request(r, NGX_HTTP_BAD_GATEWAY);
        /* BUG: does not return — falls through */
    }

    /* BUG: if error path ran, r->pool may already be destroyed.
     * accessing ctx is use-after-free; second finalize
     * double-decrements count */
    ctx->response_status = u->headers_in.status_n;
    ngx_http_finalize_request(r, NGX_OK);
}
```

**Correct (single finalize per code path with immediate return):**

```c
static void
ngx_http_mymodule_upstream_callback(ngx_http_request_t *r,
    ngx_http_upstream_t *u)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    if (u->headers_in.status_n != NGX_HTTP_OK) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "upstream returned %ui", u->headers_in.status_n);
        ngx_http_finalize_request(r, NGX_HTTP_BAD_GATEWAY);
        return;  /* immediate return — no further access to r */
    }

    if (ctx == NULL) {
        ngx_http_finalize_request(r, NGX_HTTP_INTERNAL_SERVER_ERROR);
        return;
    }

    ctx->response_status = u->headers_in.status_n;

    /* exactly one finalize per execution path */
    ngx_http_finalize_request(r, NGX_OK);
}
```

**Note:** When debugging double-finalize crashes, add a temporary `ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0, "finalize count=%d", r->main->count)` before each `ngx_http_finalize_request` call. If you see `count=0` in the log before a finalize, the request has already been finalized elsewhere.

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
