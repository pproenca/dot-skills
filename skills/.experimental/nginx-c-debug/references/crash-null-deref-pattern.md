---
title: Recognize NULL Pointer Dereference Patterns in nginx Modules
impact: CRITICAL
impactDescription: causes 60%+ of nginx module segfaults
tags: crash, null-pointer, segfault, allocation
---

## Recognize NULL Pointer Dereference Patterns in nginx Modules

NULL pointer dereferences are the most common crash in nginx modules. They arise from three recurring patterns: unchecked allocation returns from `ngx_palloc`/`ngx_pcalloc` when pools are exhausted, accessing request fields after `ngx_http_finalize_request` has destroyed the request, and dereferencing module context pointers obtained via `ngx_http_get_module_ctx` without verifying that the context was previously set. Under memory pressure or unusual request flows, any of these NULL pointers will crash the worker process.

**Incorrect (uses module context without NULL check, crashes on first request without context):**

```c
static ngx_int_t
ngx_http_mymodule_access_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    /* BUG: ctx is NULL if no prior phase set it — segfault */
    if (ctx->authenticated) {
        return NGX_OK;
    }

    /* BUG: allocation not checked either */
    ctx = ngx_palloc(r->pool, sizeof(my_ctx_t));
    ctx->authenticated = 0;
    ctx->attempts = 0;

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    return NGX_HTTP_FORBIDDEN;
}
```

**Correct (checks every pointer before dereference, handles allocation failure):**

```c
static ngx_int_t
ngx_http_mymodule_access_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    if (ctx != NULL) {
        /* context exists from a prior phase — safe to read */
        if (ctx->authenticated) {
            return NGX_OK;
        }

        return NGX_HTTP_FORBIDDEN;
    }

    /* first invocation: allocate and zero-initialize context */
    ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* pcalloc zeros all fields: authenticated=0, attempts=0 */
    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    return NGX_HTTP_FORBIDDEN;
}
```

**Note:** Use `ngx_pcalloc` instead of `ngx_palloc` for context structs so all pointer fields start as NULL and all integer fields as zero. This prevents reading uninitialized memory if a code path accesses a field before it is explicitly set.

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
