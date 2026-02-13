---
title: Use Module Context for Per-Request State
impact: HIGH
impactDescription: prevents global state corruption across concurrent requests
tags: handler, context, per-request, state
---

## Use Module Context for Per-Request State

Each request needs its own isolated state. `ngx_http_set_ctx` associates a module-specific context with a request, and `ngx_http_get_module_ctx` retrieves it. Using global variables or static data for per-request state causes concurrent requests to corrupt each other's data, since a single worker handles thousands of requests interleaved by the event loop.

**Incorrect (static variable shared across all concurrent requests):**

```c
/* BUG: single instance shared by ALL requests in this worker */
static my_ctx_t  global_ctx;

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    /* BUG: request A's data is overwritten when request B arrives */
    global_ctx.uri = r->uri;
    global_ctx.state = STATE_INIT;

    return ngx_http_mymodule_process(r, &global_ctx);
}
```

**Correct (per-request context allocated from request pool):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    /* check if context already exists (e.g., re-entry after async) */
    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    if (ctx == NULL) {
        /* first call — allocate and initialize context */
        ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
        if (ctx == NULL) {
            return NGX_ERROR;
        }

        ctx->state = STATE_INIT;

        /* bind context to this request for this module */
        ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);
    }

    /* ctx is isolated per-request — safe with concurrent requests */
    return ngx_http_mymodule_process(r, ctx);
}
```

**Note:** The context is automatically freed when `r->pool` is destroyed at request end. Always use `ngx_pcalloc` to zero-initialize the context so all pointers start as NULL and all integers as 0. The `get_module_ctx` / `set_ctx` pair is used in virtually every nginx module — filters, access handlers, and upstream modules all follow this pattern.

Reference: [nginx Development Guide — HTTP Request](https://nginx.org/en/docs/dev/development_guide.html#http_request)
