---
title: Use Correct Debug Mask for Targeted Log Filtering
impact: MEDIUM-HIGH
impactDescription: reduces debug log noise by 90%+
tags: dbglog, debug-mask, log-level, filtering
---

## Use Correct Debug Mask for Targeted Log Filtering

The `ngx_log_debug` macros accept a mask parameter (`NGX_LOG_DEBUG_HTTP`, `NGX_LOG_DEBUG_EVENT`, `NGX_LOG_DEBUG_ALLOC`, etc.) that categorizes debug output by subsystem. Using the wrong mask means your debug messages either never appear when you enable selective debugging, or they flood the log mixed in with thousands of unrelated core messages. HTTP module debug output should use `NGX_LOG_DEBUG_HTTP`; memory debugging uses `NGX_LOG_DEBUG_ALLOC`; event loop tracing uses `NGX_LOG_DEBUG_EVENT`.

**Incorrect (using NGX_LOG_DEBUG_CORE for all messages, defeating subsystem filtering):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_conf_t  *conf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* BAD: NGX_LOG_DEBUG_CORE makes this appear at ALL debug levels.
     * When nginx is configured with `error_log debug_http`, this
     * message won't show. When configured with plain `debug`, this
     * message floods alongside every event loop and alloc trace. */
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

**Correct (using subsystem-specific masks for targeted filtering):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_http_mymodule_ctx_t   *ctx;
    ngx_http_mymodule_conf_t  *conf;

    conf = ngx_http_get_module_loc_conf(r, ngx_http_mymodule_module);

    /* NGX_LOG_DEBUG_HTTP — only appears with error_log debug_http
     * or full debug; filtered out with debug_event, debug_alloc */
    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: processing uri \"%V\"", &r->uri);

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: conf value = %d", conf->value);

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    /* NGX_LOG_DEBUG_ALLOC — only appears with debug_alloc or full
     * debug; use for allocation-heavy tracing during leak hunts */
    ngx_log_debug2(NGX_LOG_DEBUG_ALLOC, r->connection->log, 0,
                   "mymodule: allocated ctx %uz bytes at %p",
                   sizeof(ngx_http_mymodule_ctx_t), ctx);

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    return NGX_DECLINED;
}
```

Reference: [nginx Debugging Log](https://nginx.org/en/docs/debugging_log.html)
