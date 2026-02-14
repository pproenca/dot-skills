---
title: Use Correct Debug Mask for Targeted Log Filtering
impact: MEDIUM-HIGH
impactDescription: reduces debug log noise by 90%+
tags: dbglog, debug-mask, log-level, filtering
---

## Use Correct Debug Mask for Targeted Log Filtering

The `ngx_log_debug` macros accept a mask parameter (`NGX_LOG_DEBUG_HTTP`, `NGX_LOG_DEBUG_EVENT`, `NGX_LOG_DEBUG_ALLOC`, etc.) that categorizes debug output by subsystem. These masks are C-level constants checked via bitwise AND against `log->log_level`. From nginx.conf, `error_log ... debug` enables ALL debug masks — there is no config-level way to selectively enable only HTTP or event debug messages. However, using the correct mask per subsystem lets you filter debug output via `grep` after capture, separating HTTP request traces from event loop noise and allocation tracking.

**Incorrect (using NGX_LOG_DEBUG_CORE for HTTP module output, defeating grep filtering):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_conf_t  *conf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* BAD: NGX_LOG_DEBUG_CORE makes this indistinguishable from
     * core debug output. When grepping logs by subsystem, these
     * HTTP-related messages mix with event loop and core traces,
     * making it impossible to isolate module behavior. */
    ngx_log_debug1(NGX_LOG_DEBUG_CORE, r->connection->log, 0,
                   "mymodule: processing uri \"%V\"", &r->uri);

    ngx_log_debug1(NGX_LOG_DEBUG_CORE, r->connection->log, 0,
                   "mymodule: conf value = %d", conf->value);

    /* Even memory-related debug output uses CORE */
    ngx_log_debug2(NGX_LOG_DEBUG_CORE, r->connection->log, 0,
                   "mymodule: allocated %uz bytes at %p",
                   sizeof(ngx_http_mymodule_ctx_t),
                   ngx_pcalloc(r->pool,
                               sizeof(ngx_http_mymodule_ctx_t)));

    return NGX_DECLINED;
}
```

**Correct (using subsystem-specific masks for post-hoc grep filtering):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_ctx_t   *ctx;
    ngx_http_mymodule_conf_t  *conf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* NGX_LOG_DEBUG_HTTP — categorizes output as HTTP subsystem.
     * grep for "http" in debug logs to isolate request traces. */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: processing uri \"%V\"", &r->uri);

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: conf value = %d", conf->value);

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    /* NGX_LOG_DEBUG_ALLOC — categorizes output as allocation
     * subsystem; use for leak-hunting sessions where you grep
     * for allocation traces specifically */
    ngx_log_debug2(NGX_LOG_DEBUG_ALLOC, r->connection->log, 0,
                   "mymodule: allocated ctx %uz bytes at %p",
                   sizeof(ngx_http_mymodule_ctx_t), ctx);

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    return NGX_DECLINED;
}
```

Reference: [nginx Debugging Log](https://nginx.org/en/docs/debugging_log.html)
