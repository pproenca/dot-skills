---
title: Read nginx Backtrace to Identify Crash Module and Phase
impact: HIGH
impactDescription: maps crash to specific module and request phase
tags: gdb, backtrace, stack-trace, phase
---

## Read nginx Backtrace to Identify Crash Module and Phase

An nginx backtrace reveals the crash location through the function call chain. Key functions identify the execution context: `ngx_http_*_handler` functions indicate the request phase, `ngx_http_*_filter` functions show filter chain position, `ngx_http_upstream_*` functions reveal upstream proxy state, and `ngx_http_finalize_request` indicates cleanup. Frame 0 shows the immediate crash site, but frames further up show why that code path was reached, which is often more important for determining the fix.

**Incorrect (looking only at frame 0 and fixing the symptom):**

```c
/*
 * Backtrace from coredump:
 *
 * (gdb) bt
 * #0  0x00005612a3c1f8a0 in ngx_http_mymodule_process ()
 * #1  0x00005612a3b8e200 in ngx_http_upstream_process_body_in_memory ()
 * #2  0x00005612a3b8a140 in ngx_http_upstream_handler ()
 * #3  0x00005612a3b71c00 in ngx_epoll_process_events ()
 * #4  0x00005612a3b68400 in ngx_process_events_and_timers ()
 * #5  0x00005612a3b6f800 in ngx_worker_process_cycle ()
 *
 * BAD approach: look only at frame 0, see a NULL dereference
 * in ngx_http_mymodule_process, add a NULL check, and move on.
 */

static ngx_int_t
ngx_http_mymodule_process(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    /* "Fix" — add NULL check (treats symptom, not cause) */
    if (ctx == NULL) {
        return NGX_ERROR;  /* why is ctx NULL here? unknown */
    }

    /* the real question: why did the upstream body callback
     * reach this module when context was never initialized?  */
    return ctx->handler(r, ctx);
}
```

**Correct (reading the full backtrace to identify phase and root cause):**

```c
/*
 * Read the backtrace bottom-to-top for context:
 *
 * (gdb) bt full
 * #5  ngx_worker_process_cycle   → worker event loop
 * #4  ngx_process_events_and_timers → epoll returned an event
 * #3  ngx_epoll_process_events   → socket became readable
 * #2  ngx_http_upstream_handler  → upstream event dispatched
 * #1  ngx_http_upstream_process_body_in_memory → reading body
 * #0  ngx_http_mymodule_process  → OUR CODE — crash here
 *
 * Analysis: the crash happens during upstream body processing
 * (frame #1), NOT during normal phase handling. This means:
 * - The request is in upstream state, not phase engine state
 * - ctx must be set BEFORE upstream is initiated
 *
 * (gdb) frame 1
 * (gdb) print u->input_filter_ctx
 * $1 = (void *) 0x0
 *
 * Root cause: input_filter_ctx was not set when upstream
 * was initialized. The module's create_request callback
 * forgot to assign u->input_filter_ctx = ctx.
 */

/* Fix: set input_filter_ctx during upstream initialization */
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t            *ctx;
    ngx_http_upstream_t *u;

    ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    if (ngx_http_upstream_create(r) != NGX_OK) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    u = r->upstream;
    u->input_filter_init = ngx_http_mymodule_filter_init;
    u->input_filter = ngx_http_mymodule_filter;
    u->input_filter_ctx = ctx;  /* ROOT CAUSE FIX */

    return NGX_OK;
}
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
