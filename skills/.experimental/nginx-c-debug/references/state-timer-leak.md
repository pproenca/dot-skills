---
title: Detect Timer Leaks from Events Not Removed Before Pool Destruction
impact: MEDIUM
impactDescription: causes use-after-free when timer fires on freed data
tags: state, timer, leak, event, use-after-free
---

## Detect Timer Leaks from Events Not Removed Before Pool Destruction

When a timer event references data allocated from a memory pool, destroying the pool without first deleting the timer leaves a dangling pointer in the event timer tree. When the timer eventually fires, the event handler dereferences freed memory, causing use-after-free corruption or segfaults. These bugs are particularly insidious because they manifest at unpredictable times after the original request is long gone, making the crash backtrace point to timer dispatch code rather than the module that leaked the timer. Always register a pool cleanup handler that removes outstanding timers.

**Incorrect (destroying a request pool without removing outstanding timer events):**

```c
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_event_t              *timer_ev;
    ngx_http_mymodule_ctx_t  *ctx;

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    /* Allocate a timer event from the request pool */
    timer_ev = ngx_pcalloc(r->pool, sizeof(ngx_event_t));
    if (timer_ev == NULL) {
        return NGX_ERROR;
    }

    timer_ev->handler = ngx_http_mymodule_timeout;
    timer_ev->data = ctx;  /* points to pool-allocated data */
    timer_ev->log = r->connection->log;

    /* Add a 30-second timer */
    ngx_add_timer(timer_ev, 30000);

    ctx->timer_event = timer_ev;

    /* BUG: no cleanup handler registered.
     * If the request finishes (or client disconnects) before
     * the 30s timer fires, the pool is destroyed but the timer
     * remains in the event timer rbtree.
     *
     * 30 seconds later, ngx_event_expire_timers() fires this
     * event, calling ngx_http_mymodule_timeout() with ctx
     * pointing to freed pool memory.
     *
     * Crash backtrace will show:
     *   #0 ngx_http_mymodule_timeout()
     *   #1 ngx_event_expire_timers()
     *   #2 ngx_process_events_and_timers()
     * with corrupted ctx data — very hard to trace back to
     * the missing cleanup. */

    return NGX_DECLINED;
}
```

**Correct (registering a cleanup handler to remove timers before pool destruction):**

```c
/* Cleanup handler — called automatically when pool is destroyed */
static void
ngx_http_mymodule_cleanup(void *data)
{
    ngx_http_mymodule_ctx_t *ctx = data;

    /* Remove the timer from the event tree BEFORE the pool
     * (and therefore ctx and timer_event) are freed */
    if (ctx->timer_event && ctx->timer_event->timer_set) {
        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, ctx->timer_event->log, 0,
                       "mymodule: cleanup removing outstanding timer");
        ngx_del_timer(ctx->timer_event);
    }
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_event_t              *timer_ev;
    ngx_pool_cleanup_t       *cln;
    ngx_http_mymodule_ctx_t  *ctx;

    ctx = ngx_pcalloc(r->pool, sizeof(ngx_http_mymodule_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    /* Register cleanup BEFORE adding the timer, so if any
     * subsequent allocation fails, cleanup is still in place */
    cln = ngx_pool_cleanup_add(r->pool, 0);
    if (cln == NULL) {
        return NGX_ERROR;
    }

    cln->handler = ngx_http_mymodule_cleanup;
    cln->data = ctx;

    /* Allocate and configure the timer event */
    timer_ev = ngx_pcalloc(r->pool, sizeof(ngx_event_t));
    if (timer_ev == NULL) {
        return NGX_ERROR;
    }

    timer_ev->handler = ngx_http_mymodule_timeout;
    timer_ev->data = ctx;
    timer_ev->log = r->connection->log;

    ngx_add_timer(timer_ev, 30000);

    ctx->timer_event = timer_ev;

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: timer set with cleanup registered");

    return NGX_DECLINED;
}
```

Reference: [nginx Development Guide — Pool Cleanup](https://nginx.org/en/docs/dev/development_guide.html#pool)
