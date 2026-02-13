---
title: Avoid Crashes from error_page Internal Redirect Context Invalidation
impact: CRITICAL
impactDescription: crashes on stale context after redirect
tags: crash, error-page, redirect, context, use-after-free
---

## Avoid Crashes from error_page Internal Redirect Context Invalidation

When `error_page` triggers an internal redirect, nginx resets the request's module context array. Module context pointers obtained via `ngx_http_get_module_ctx` before the redirect become stale — they point to memory that may be freed or reallocated during the redirect. This is a common source of intermittent production crashes, especially under SSL with long-lived connections where the timing allows the pool to be partially reused. The crash signature shows access to data that looks structurally valid but contains wrong values, because the memory has been repurposed.

**Incorrect (saves ctx pointer before an operation that may trigger error_page, uses it after redirect):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t   *ctx;
    ngx_int_t   rc;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
        if (ctx == NULL) {
            return NGX_HTTP_INTERNAL_SERVER_ERROR;
        }
        ctx->original_uri = r->uri;
        ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);
    }

    /* this may return 404, triggering error_page 404 /fallback */
    rc = ngx_http_mymodule_lookup(r);

    if (rc == NGX_HTTP_NOT_FOUND) {
        return rc;  /* nginx processes error_page internally */
    }

    /* BUG: if error_page triggered an internal redirect in a
     * previous call, ctx now points to stale/freed memory.
     * The internal redirect reset the module context array. */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: original_uri=\"%V\"",
                   &ctx->original_uri);

    return NGX_OK;
}
```

**Correct (re-fetches module context after any operation that may trigger an internal redirect):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t   *ctx;
    ngx_int_t   rc;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
        if (ctx == NULL) {
            return NGX_HTTP_INTERNAL_SERVER_ERROR;
        }
        ctx->original_uri = r->uri;
        ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);
    }

    rc = ngx_http_mymodule_lookup(r);

    if (rc == NGX_HTTP_NOT_FOUND) {
        return rc;
    }

    /* re-fetch context after any operation that may have
     * triggered an internal redirect via error_page */
    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        /* context was lost during redirect — re-establish it */
        ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
        if (ctx == NULL) {
            return NGX_HTTP_INTERNAL_SERVER_ERROR;
        }
        ctx->original_uri = r->uri;
        ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);
    }

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: original_uri=\"%V\"",
                   &ctx->original_uri);

    return NGX_OK;
}
```

**Note:** An alternative defensive pattern is to store critical state on the main request's context (`r->main`) rather than on the subrequest or redirected request context, since `r->main` survives internal redirects. Use `ngx_http_get_module_ctx(r->main, ...)` when the state must persist across redirects.

Reference: [Coredump Debug Story About Nginx](https://api7.ai/blog/coredump-debug-story-about-nginx)
